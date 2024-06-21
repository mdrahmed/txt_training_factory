/*
 * TxtMultiProcessingStationRun.cpp
 *
 *  Created on: 03.04.2019
 *      Author: steiger-a
 */

#ifndef __DOCFSM__
#include "TxtMultiProcessingStation.h"

#include "TxtMqttFactoryClient.h"

#include "spdlog/spdlog.h"
#include "spdlog/sinks/stdout_color_sinks.h"
#endif

#ifdef FSM_INIT_FSM
#undef FSM_INIT_FSM
#endif
#define FSM_INIT_FSM(startState, attr...) \
	currentState = startState;            \
	newState = startState;

#ifdef FSM_TRANSITION
#undef FSM_TRANSITION
#endif
#ifdef _DEBUG
#define FSM_TRANSITION(_newState, attr...)              \
	do                                                  \
	{                                                   \
		std::cerr << state2str(currentState) << " -> "  \
				  << state2str(_newState) << std::endl; \
		newState = _newState;                           \
	} while (false)
#else
#define FSM_TRANSITION(_newState, attr...) newState = _newState
#endif

auto duration = std::chrono::milliseconds(0);
auto mpo_processing_ms = std::chrono::high_resolution_clock::now();
auto mpo2sld_ms = std::chrono::high_resolution_clock::now();
auto end_ms = std::chrono::high_resolution_clock::now();

namespace ft
{
	time_t start, mpo_processing, mpo2sld, end;
	double time_taken;

	// Collecting all current time
	std::string getCurrentTime()
	{
		// Get the current time
		auto now = std::chrono::system_clock::now();

		// Convert to time_t to get calendar time
		std::time_t now_c = std::chrono::system_clock::to_time_t(now);

		// Create a tm structure to hold the local time
		std::tm local_tm = *std::localtime(&now_c);

		// Format the time as a string
		std::ostringstream oss;
		oss << std::put_time(&local_tm, "%Y-%m-%d %H:%M:%S");

		return oss.str();
	}

	std::string getHighResolutionTime()
	{
		// Get the current high-resolution time
		auto now = std::chrono::high_resolution_clock::now();

		// Get the duration since epoch
		auto duration = now.time_since_epoch();

		// Convert the duration to milliseconds
		auto millis = std::chrono::duration_cast<std::chrono::milliseconds>(duration).count();

		return std::to_string(millis) + " ms since epoch";
	}

	std::time_t getUnixTime()
	{
		// Get the current time
		auto now = std::chrono::system_clock::now();

		// Convert to time_t to get UNIX time
		return std::chrono::system_clock::to_time_t(now);
	}

	void TxtMultiProcessingStation::fsmStep()
	{
		std::string currentTime = getCurrentTime();
		std::string highResTime = getHighResolutionTime();
		std::time_t unixTime = getUnixTime();

		std::cout << "TxtMultiProcessingStation" << std::endl;
		std::cout << "Current local time: " << currentTime << std::endl;
		std::cout << "High resolution time: " << highResTime << std::endl;
		std::cout << "UNIX time: " << unixTime << " seconds since epoch" << std::endl;

		std::cout << "reqQuit" << reqQuit << std::endl;
		std::cout << "reqVGRproduce:" << reqVGRproduce << std::endl;
		std::cout << "reqSLDstarted:" << reqSLDstarted << std::endl;
		std::cout << "chMsaw:" << chMsaw << std::endl;

		SPDLOG_LOGGER_TRACE(spdlog::get("console"), "fsmStep", 0);

		// Entry activities ===============================================
		if (newState != currentState)
		{
			switch (newState)
			{
			//-------------------------------------------------------------
			case FAULT:
			{
				printEntryState(FAULT);
				setStatus(SM_ERROR);
				sound.error();
				break;
			}
			//-------------------------------------------------------------
			case IDLE:
			{
				printEntryState(IDLE);
				setActStatus(false, SM_READY);
				break;
			}
			//-------------------------------------------------------------
			default:
				break;
			}
			currentState = newState;
		}

		// Do activities ==================================================
		switch (currentState)
		{
		//-----------------------------------------------------------------
		case FAULT:
		{
			printState(FAULT);
			if (reqQuit)
			{
				setStatus(SM_READY);
				FSM_TRANSITION(IDLE, color = green, label = 'req\nquit');
				reqQuit = false;
			}
#ifdef __DOCFSM__
			FSM_TRANSITION(FAULT, color = red, label = 'wait');
#endif
			std::this_thread::sleep_for(std::chrono::milliseconds(1000));
			break;
		}
		//-----------------------------------------------------------------
		case INIT:
		{
			printState(INIT);
#ifdef __DOCFSM__ // TODO remove, needed for graph
			FSM_TRANSITION(INIT);
#endif
			setCompressor(true);
			setValveOvenDoor(true);
			std::this_thread::sleep_for(std::chrono::milliseconds(300));

			std::thread tG = axisGripper.moveS1Thread();
			std::thread tR = axisRotTable.moveS1Thread();
			std::thread tO = axisOvenInOut.moveS1Thread();
			tO.join();
			tR.join();
			tG.join();

			setCompressor(false);
			FSM_TRANSITION(IDLE, color = green, label = 'initialized');
			break;
		}
		//-----------------------------------------------------------------
		case IDLE:
		{
			// printState(IDLE);
			if (reqVGRproduce)
			{
				time(&mpo_processing);
				std::cout << "mpo_processing start time: " << mpo_processing;

				// mpo_processing_ms = std::chrono::high_resolution_clock::now();

				auto start = std::chrono::system_clock::now();
				while (!isOvenTriggered())
				{
					auto end = std::chrono::system_clock::now();
					auto dur = end - start;
					auto diff_s = std::chrono::duration_cast<std::chrono::duration<float>>(dur).count();
					double diff_max = 5.0;
					if (diff_s > diff_max)
					{
						FSM_TRANSITION(FAULT, color = red, label = 'timeout\n5 sec');
						break;
					}
					std::this_thread::sleep_for(std::chrono::milliseconds(10));
				}

				assert(mqttclient);
				mqttclient->publishMPO_Ack(MPO_STARTED, TIMEOUT_MS_PUBLISH);

				FSM_TRANSITION(BURN, color = blue, label = 'req\nVGR');
				reqVGRproduce = false;
			}
#ifdef __DOCFSM__
			FSM_TRANSITION(IDLE, color = green, label = 'wait');
#endif
			break;
		}
		//-----------------------------------------------------------------
		case BURN:
		{
			printState(BURN);

			setActStatus(true, SM_BUSY);

			// in
			setCompressor(true);
			std::this_thread::sleep_for(std::chrono::milliseconds(2500));
			axisOvenInOut.moveS2();
			setValveOvenDoor(false);
			std::this_thread::sleep_for(std::chrono::milliseconds(1000));

			std::thread tGripper = axisGripper.moveS2Thread();

			// burn
			for (int i = 0; i < 14; i++)
			{
				setLightOven(true);
				std::this_thread::sleep_for(std::chrono::milliseconds(200));
				setLightOven(false);
				std::this_thread::sleep_for(std::chrono::milliseconds(200));
			}
			std::this_thread::sleep_for(std::chrono::milliseconds(1000));

			// out
			setCompressor(true);
			setValveOvenDoor(true);
			axisOvenInOut.moveS1();

			tGripper.join();

			FSM_TRANSITION(VGR_TRANSPORT, color = blue, label = 'burned');
			break;
		}
		//-----------------------------------------------------------------
		case VGR_TRANSPORT:
		{
			time(&end);

			end_ms = std::chrono::high_resolution_clock::now();
			time_taken = double(end - mpo_processing);
			std::cout << "MPO_processing time taken is : " << std::fixed
					  << time_taken << std::setprecision(5);
			std::cout << " sec " << std::endl;
			duration = std::chrono::duration_cast<std::chrono::milliseconds>(end_ms - mpo_processing_ms);
			std::cout << "MPO processing miliseconds time taken: " << duration.count() << "ms" << std::endl;

			time(&mpo2sld);
			std::cout << "mpo2sld start time: " << mpo2sld;

			printState(VGR_TRANSPORT);
			axisRotTable.moveS1();

			// pickup
			setValveLowering(true);
			std::this_thread::sleep_for(std::chrono::milliseconds(1000));
			setValveVacuum(true);
			std::this_thread::sleep_for(std::chrono::milliseconds(1000));
			setValveLowering(false);

			// move
			axisGripper.moveS1();

			// release
			setValveLowering(true);
			std::this_thread::sleep_for(std::chrono::milliseconds(400));
			setValveVacuum(false);
			std::this_thread::sleep_for(std::chrono::milliseconds(300));
			setValveLowering(false);
			std::this_thread::sleep_for(std::chrono::milliseconds(500));

			setCompressor(false);
			FSM_TRANSITION(TABLE_SAW, color = blue, label = 'transported');
			break;
		}
		//-----------------------------------------------------------------
		case TABLE_SAW:
		{
			printState(TABLE_SAW);
			axisRotTable.moveS2();
			std::this_thread::sleep_for(std::chrono::milliseconds(1000));
			setSawRight();
			std::this_thread::sleep_for(std::chrono::milliseconds(2500));
			setSawOff();
			setSawLeft();
			std::this_thread::sleep_for(std::chrono::milliseconds(2500));
			setSawOff();
			std::this_thread::sleep_for(std::chrono::milliseconds(1000));
			FSM_TRANSITION(TABLE_BELT, color = blue, label = 'processed');
			break;
		}
		//-----------------------------------------------------------------
		case TABLE_BELT:
		{
			printState(TABLE_BELT);
			axisRotTable.moveS3();
			FSM_TRANSITION(EJECT, color = blue, label = 'produced');
			break;
		}
		//-----------------------------------------------------------------
		case EJECT:
		{
			printState(EJECT);
			convBelt.moveRight();
			setCompressor(true);
			std::this_thread::sleep_for(std::chrono::milliseconds(400));
			// eject
			setValveEjection(true);
			std::this_thread::sleep_for(std::chrono::milliseconds(100));
			setValveEjection(false);
			setCompressor(false);

			assert(mqttclient);
			mqttclient->publishMPO_Ack(MPO_PRODUCED, TIMEOUT_MS_PUBLISH);

			FSM_TRANSITION(TRANSPORT, color = blue, label = 'ejected');
			break;
		}
		//-----------------------------------------------------------------
		case TRANSPORT:
		{
			printState(TRANSPORT);
			setActStatus(false, SM_READY);
			/* TODO
			if (reqSLDstarted)
			{*/
			auto start = std::chrono::system_clock::now();
			while (!isEndConveyorBeltTriggered())
			{
				auto end = std::chrono::system_clock::now();
				auto dur = end - start;
				auto diff_s = std::chrono::duration_cast<std::chrono::duration<float>>(dur).count();
				double diff_max = 10.0;
				if (diff_s > diff_max)
				{
					FSM_TRANSITION(FAULT, color = red, label = 'timeout\n10 sec');
					break;
				}
				std::this_thread::sleep_for(std::chrono::milliseconds(10));
			}
			std::this_thread::sleep_for(std::chrono::milliseconds(2000));
			convBelt.stop();
			FSM_TRANSITION(IDLE, color = green, label = 'next');
			/*	reqSLDstarted = false;
			}
	#ifdef __DOCFSM__
			FSM_TRANSITION( TRANSPORT, color=blue, label='wait' );
	#endif
			*/
			break;
		}
		//-----------------------------------------------------------------
		default:
			assert(0);
			break;
		}

		if (newState == currentState)
			return;

		// Exit activities ================================================
		switch (currentState)
		{
		//-----------------------------------------------------------------
		//-----------------------------------------------------------------
		default:
			break;
		}
	}

	void TxtMultiProcessingStation::run()
	{
		time(&start);
		std::cout << start << std::endl;
		SPDLOG_LOGGER_TRACE(spdlog::get("console"), "run", 0);
		assert(mqttclient);
		obs_mpo = new TxtMultiProcessingStationObserver(this, mqttclient);

		FSM_INIT_FSM(INIT, color = black, label = 'init');
		while (!m_stoprequested)
		{
			fsmStep();
			std::this_thread::sleep_for(std::chrono::milliseconds(10));

			time(&end);
			std::cout << end << std::endl;
			double time_taken_whole_process = double(end - start);
			std::cout << "MPO: TOTAL Time taken by mpo program is : " << std::fixed
					  << time_taken_whole_process << std::setprecision(5);
			std::cout << " sec " << std::endl;

			end_ms = std::chrono::high_resolution_clock::now();
			time_taken = double(end - mpo2sld);
			std::cout << "MPO to Sorting Line time taken is : " << std::fixed
					  << time_taken << std::setprecision(5);
			std::cout << " sec " << std::endl;
			duration = std::chrono::duration_cast<std::chrono::milliseconds>(end_ms - mpo2sld_ms);
			std::cout << "MPO to Sorting Line miliseconds time taken: " << duration.count() << "ms" << std::endl;
		}

		assert(mqttclient);
		mqttclient->publishMPO_Ack(MPO_EXIT, TIMEOUT_MS_PUBLISH);
	}

} /* namespace ft */
