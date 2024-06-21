/*
 * TxtHighBayWarehouseRun.cpp
 *
 *  Created on: 07.02.2019
 *      Author: steiger-a
 */

#ifndef __DOCFSM__
#include "TxtHighBayWarehouse.h"

#include "TxtMqttFactoryClient.h"
#include "Utils.h"

#include <bits/stdc++.h>
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
auto hbw_retrieval_ms = std::chrono::high_resolution_clock::now();
auto hbw_storage_ms = std::chrono::high_resolution_clock::now();
auto end_ms = std::chrono::high_resolution_clock::now();

namespace ft
{
	time_t start, hbw_retrieval = 0, hbw_storage = 0, end;

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

	void TxtHighBayWarehouse::fsmStep()
	{
		std::string currentTime = getCurrentTime();
		std::string highResTime = getHighResolutionTime();
		std::time_t unixTime = getUnixTime();

		std::cout << "TxtHighBayWarehouse" << std::endl;
		std::cout << "Current local time: " << currentTime << std::endl;
		std::cout << "High resolution time: " << highResTime << std::endl;
		std::cout << "UNIX time: " << unixTime << " seconds since epoch" << std::endl;

		std::cout << "reqQuit" << reqQuit << std::endl;
		std::cout << "reqVGRfetchContainer:" << reqVGRfetchContainer << std::endl;
		std::cout << "reqVGRstore:" << reqVGRstore << std::endl;
		std::cout << "reqVGRfetch:" << reqVGRfetch << std::endl;
		std::cout << "reqVGRstoreContainer:" << reqVGRstoreContainer << std::endl;
		std::cout << "reqVGRcalib:" << reqVGRcalib << std::endl;
		std::cout << "reqVGRresetStorage:" << reqVGRresetStorage << std::endl;
		std::cout << "reqJoyData:" << reqJoyData << std::endl;

		SPDLOG_LOGGER_TRACE(spdlog::get("console"), "fsmStep", 0);

		// Entry activities ===================================================
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
			//-----------------------------------------------------------------
			case IDLE:
			{
				printEntryState(IDLE);
				setSpeed(512);
				moveRef();
				setActStatus(false, SM_READY);
				publishStorage();
				break;
			}
			//-----------------------------------------------------------------
			case CALIB_HBW:
			{
				printEntryState(CALIB_HBW);
				sound.info2();
				moveRef();
				break;
			}
			//-----------------------------------------------------------------
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
			moveRef();
			FSM_TRANSITION(IDLE, color = green, label = 'initialized');
			break;
		}
		//-----------------------------------------------------------------
		case IDLE:
		{
			// FSM_TRANSITION( FETCH_CONTAINER, color=blue, label='req fetch\ncontainer' );
			// printState(IDLE);
			if (reqVGRfetchContainer)
			{
				time(&hbw_storage);
				std::cout << "hbw_storage start time: " << hbw_storage;
				hbw_storage_ms = std::chrono::high_resolution_clock::now();

				FSM_TRANSITION(FETCH_CONTAINER, color = blue, label = 'req fetch\ncontainer');
				reqVGRfetchContainer = false;
			}
			else if (reqVGRfetch)
			{
				time(&hbw_retrieval);
				std::cout << "hbw_retrieval start time: " << hbw_retrieval;
				hbw_retrieval_ms = std::chrono::high_resolution_clock::now();

				FSM_TRANSITION(FETCH_WP, color = blue, label = 'req fetch\nworkpiece');
				reqVGRfetch = false;
			}
			else if (reqVGRcalib)
			{
				FSM_TRANSITION(CALIB_HBW, color = orange, label = 'req\ncalib');
				reqVGRcalib = false;
			}
			else if (reqVGRresetStorage)
			{
				storage.resetStorageState();
				sound.info1();
				reqVGRresetStorage = false;
			}
#ifdef __DOCFSM__
			FSM_TRANSITION(IDLE, color = green, label = 'wait');
#endif
			break;
		}
		//-----------------------------------------------------------------
		case FETCH_CONTAINER:
		{
			printState(FETCH_CONTAINER);
			if (fetchContainer())
			{
				assert(mqttclient);
				mqttclient->publishHBW_Ack(HBW_FETCHED, reqVGRwp, TIMEOUT_MS_PUBLISH);

				FSM_TRANSITION(STORE_WP, color = blue, label = 'req\nstore');
			}
			else
			{
				FSM_TRANSITION(FAULT, color = red, label = 'error');
			}
#ifdef __DOCFSM__
			FSM_TRANSITION(FETCH_CONTAINER, color = blue, label = 'wait');
#endif
			break;
		}
		//-----------------------------------------------------------------
		case STORE_WP:
		{
			printState(STORE_WP);
			if (reqVGRstore)
			{
				if (reqVGRwp && store(*reqVGRwp))
				{
					FSM_TRANSITION(IDLE, color = green, label = 'workpiece\nstored');
				}
				else
				{
					FSM_TRANSITION(FAULT, color = red, label = 'error');
				}
				reqVGRstore = false;
			}
#ifdef __DOCFSM__
			FSM_TRANSITION(STORE_WP, color = blue, label = 'wait');
#endif
			break;
		}
		//-----------------------------------------------------------------
		case FETCH_WP:
		{
			printState(FETCH_WP);
			if (reqVGRwp && fetch(reqVGRwp->type))
			{
				assert(mqttclient);
				mqttclient->publishHBW_Ack(HBW_FETCHED, reqVGRwp, TIMEOUT_MS_PUBLISH);
				FSM_TRANSITION(FETCH_WP_WAIT, color = blue, label = 'wait req');
			}
			else
			{
				FSM_TRANSITION(FAULT, color = red, label = 'error');
			}
#ifdef __DOCFSM__
			FSM_TRANSITION(FETCH_WP, color = blue, label = 'wait');
#endif
			break;
		}
		//-----------------------------------------------------------------
		case FETCH_WP_WAIT:
		{
			printState(FETCH_WP_WAIT);
			if (reqVGRstoreContainer)
			{
				FSM_TRANSITION(STORE_CONTAINER, color = blue, label = 'req store\ncontainer');
				reqVGRstoreContainer = false;
			}
#ifdef __DOCFSM__
			FSM_TRANSITION(FETCH_WP_WAIT, color = blue, label = 'wait');
#endif
			break;
		}
		//-----------------------------------------------------------------
		case STORE_CONTAINER:
		{
			printState(STORE_CONTAINER);
			if (storeContainer())
			{
				FSM_TRANSITION(IDLE, color = green, label = 'container\nstored');
			}
			else
			{
				FSM_TRANSITION(FAULT, color = red, label = 'error');
			}
#ifdef __DOCFSM__
			FSM_TRANSITION(STORE_CONTAINER, color = blue, label = 'wait');
#endif
			break;
		}
		//-----------------------------------------------------------------
		case CALIB_HBW:
		{
			printState(CALIB_HBW);
			setStatus(SM_CALIB);
			calibPos = (TxtHbwCalibPos_t)0;
			FSM_TRANSITION(CALIB_HBW_NAV, color = orange, label = 'init');
			break;
		}
		//-----------------------------------------------------------------
		case CALIB_HBW_NAV:
		{
			printState(CALIB_HBW_NAV);
			bool reqmove = true;
			while (true)
			{
				if (joyData.b1)
				{
					break;
				}
				else if (joyData.b2)
				{
					assert(mqttclient);
					mqttclient->publishHBW_Ack(HBW_CALIB_END, 0, TIMEOUT_MS_PUBLISH);
					FSM_TRANSITION(IDLE, color = green, label = 'cancel');
					break;
				}
				else if (joyData.aX2 > 500)
				{
					calibPos = (TxtHbwCalibPos_t)(calibPos - 1);
					std::cout << ft::toString(calibPos) << std::endl;
					reqmove = true;
				}
				else if (joyData.aX2 < -500)
				{
					calibPos = (TxtHbwCalibPos_t)(calibPos + 1);
					std::cout << ft::toString(calibPos) << std::endl;
					reqmove = true;
				}
				// check pos valid
				if (calibPos < 0)
				{
					calibPos = (TxtHbwCalibPos_t)(HBWCALIB_END - 1);
				}
				else if (calibPos >= HBWCALIB_END)
				{
					calibPos = (TxtHbwCalibPos_t)0;
				}
				// move pos
				if (reqmove)
				{
					moveCalibPos();
					setStatus(SM_CALIB);
					assert(mqttclient);
					mqttclient->publishHBW_Ack(HBW_CALIB_NAV, 0, TIMEOUT_MS_PUBLISH);
					FSM_TRANSITION(CALIB_HBW_MOVE, color = orange, label = 'calib pos');
					reqmove = false;
					break;
				}
				std::this_thread::sleep_for(std::chrono::milliseconds(10));
			}
#ifdef __DOCFSM__
			FSM_TRANSITION(CALIB_HBW_NAV, color = orange, label = 'select pos');
#endif
			break;
		}
		//-----------------------------------------------------------------
		case CALIB_HBW_MOVE:
		{
			printState(CALIB_HBW_MOVE);
			// reset();
			while (true)
			{
				if (joyData.b2)
				{
					break; //-> NAV
				}
				else if (joyData.b1)
				{
					EncPos2 p2 = getPos2();
					switch (calibPos)
					{
					case HBWCALIB_A1:
						calibData.hbx[0] = p2.x;
						calibData.hby[0] = p2.y;
						calibData.save();
						break;
					case HBWCALIB_B2:
						calibData.hbx[1] = p2.x;
						calibData.hby[1] = p2.y;
						calibData.save();
						break;
					case HBWCALIB_C3:
						calibData.hbx[2] = p2.x;
						calibData.hby[2] = p2.y;
						calibData.save();
						break;
					case HBWCALIB_CV:
						calibData.conv.x = p2.x;
						calibData.conv.y = p2.y;
						calibData.save();
						break;
					default:
						break;
					}
					// same pos again
					break; //-> NAV
				}
				else if ((joyData.aX2 > 500) | (joyData.aX2 < -500))
				{
					break; //-> NAV
				}
				moveJoystick();
#ifdef __DOCFSM__
				FSM_TRANSITION(CALIB_MOVE, color = orange, label = 'move');
#endif
				std::this_thread::sleep_for(std::chrono::milliseconds(10));
			}
			FSM_TRANSITION(CALIB_HBW_NAV, color = green, label = 'ok');
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

	void TxtHighBayWarehouse::moveCalibPos()
	{
		SPDLOG_LOGGER_TRACE(spdlog::get("console"), "moveCalibPos", 0);
		switch (calibPos)
		{
		case HBWCALIB_CV:
			moveRef();
			moveConv(false);
			break;
		case HBWCALIB_A1:
			moveRef();
			moveCR(0, 0);
			break;
		case HBWCALIB_B2:
			moveRef();
			moveCR(1, 1);
			break;
		case HBWCALIB_C3:
			moveRef();
			moveCR(2, 2);
			break;
		default:
			assert(0);
			break;
		}
	}

	void TxtHighBayWarehouse::run()
	{
		time(&start);
		std::cout << "HBW start time: " << start << std::endl;
		SPDLOG_LOGGER_TRACE(spdlog::get("console"), "run", 0);
		assert(mqttclient);
		obs_hbw = new TxtHighBayWarehouseObserver(this, mqttclient);
		obs_storage = new TxtHighBayWarehouseStorageObserver(getStorage(), mqttclient);

		FSM_INIT_FSM(INIT, color = black, label = 'init');
		while (!m_stoprequested)
		{
			fsmStep();
			std::this_thread::sleep_for(std::chrono::milliseconds(10));

			time(&end);
			std::cout << end << std::endl;
			// Calculating total time taken by the program.
			double time_taken = double(end - start);
			std::cout << "HBW: TOTAL Time taken by HBW program is : " << std::fixed
					  << time_taken << std::setprecision(5);
			std::cout << " sec " << std::endl;

			end_ms = std::chrono::high_resolution_clock::now();
			if (hbw_retrieval == 0)
			{
				std::cout << "HBW Retrieval time not taken" << std::endl;
			}
			else
			{
				time_taken = double(end - hbw_retrieval);
				std::cout << "HBW Retrieval time taken: " << std::fixed
						  << time_taken << std::setprecision(5);
				std::cout << " sec " << std::endl;

				duration = std::chrono::duration_cast<std::chrono::milliseconds>(end_ms - hbw_retrieval_ms);
				std::cout << "HBW Retrieval miliseconds time taken: " << duration.count() << "ms" << std::endl;
			}
			if (hbw_storage == 0)
			{
				std::cout << "HBW Storage time not taken" << std::endl;
			}
			else
			{
				time_taken = double(end - hbw_storage);
				std::cout << "HBW Storage time taken: " << std::fixed
						  << time_taken << std::setprecision(5);
				std::cout << " sec " << std::endl;

				duration = std::chrono::duration_cast<std::chrono::milliseconds>(end_ms - hbw_storage_ms);
				std::cout << "HBW Storage miliseconds time taken: " << duration.count() << "ms" << std::endl;
			}
		}

		assert(mqttclient);
		mqttclient->publishHBW_Ack(HBW_EXIT, 0, TIMEOUT_MS_PUBLISH);
	}

} /* namespace ft */
