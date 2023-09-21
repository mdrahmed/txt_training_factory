# ICS - code analysis

## Controller Graphs 
* [FSM MPO](https://fischertechnik.github.io/txt_training_factory_doc/html/dot_TxtMultiProcessingStationRun.png)
* [FSM HBW](https://fischertechnik.github.io/txt_training_factory_doc/html/dot_TxtHighBayWarehouseRun.png)
* [FSM VGR](https://fischertechnik.github.io/txt_training_factory_doc/html/dot_TxtVacuumGripperRobotRun.png)
* [FSM SLD](https://fischertechnik.github.io/txt_training_factory_doc/html/dot_TxtSortingLineRun.png)

## Code's performing checks in a state
### VGR 
For delivery, the grip function is called from,

[`moveDeliveryInAndGrip();`](https://github.com/mdrahmed/txt_training_factory/blob/1ed18ad3cbdb572e658717b17052ecd8f3c344dc/TxtSmartFactoryLib/src/TxtVacuumGripperRobotRun.cpp#L355)

[`vgripper.grip();`](https://github.com/mdrahmed/txt_training_factory/blob/1ed18ad3cbdb572e658717b17052ecd8f3c344dc/TxtSmartFactoryLib/src/TxtVacuumGripperRobot.cpp#L274)

[grip()](https://github.com/mdrahmed/txt_training_factory/blob/master/TxtSmartFactoryLib/src/TxtVacuumGripper.cpp#L28) - This function is checking the speed of the vgr

[uid.empty()](https://github.com/mdrahmed/txt_training_factory/blob/1ed18ad3cbdb572e658717b17052ecd8f3c344dc/TxtSmartFactoryLib/src/TxtVacuumGripperRobotRun.cpp#L358) - This check is made to detect if it's wrong color in the `vgr`.

[dps.is_DIN()](https://github.com/mdrahmed/txt_training_factory/blob/1ed18ad3cbdb572e658717b17052ecd8f3c344dc/TxtSmartFactoryLib/src/TxtVacuumGripperRobotRun.cpp#L192) and [dps.is_DOUT()](https://github.com/mdrahmed/txt_training_factory/blob/1ed18ad3cbdb572e658717b17052ecd8f3c344dc/TxtSmartFactoryLib/src/TxtVacuumGripperRobotRun.cpp#L490) - Both of these conditions are used to determine the presence of the workpiece

For Storing,

[dps.getLastColor() == WP_TYPE_NONE](https://github.com/mdrahmed/txt_training_factory/blob/1ed18ad3cbdb572e658717b17052ecd8f3c344dc/TxtSmartFactoryLib/src/TxtVacuumGripperRobotRun.cpp#L535) - This condition is used to validate the workpiece.

[setTimestampNow(const std::string tag_uid, TxtHistoryIndex_t i)](https://github.com/mdrahmed/txt_training_factory/blob/master/TxtSmartFactoryLib/src/TxtFactoryProcessStorage.cpp#L26) - Within this function, it is checking the map of the testbed.


### HBW
The store and fetch functions are checking the storage and the storage is updated with this function - [`saveStorageState()`](https://github.com/mdrahmed/txt_training_factory/blob/master/TxtSmartFactoryLib/src/TxtHighBayWarehouseStorage.cpp#L98)

### MPO
**Note: `MPO` and `SLD` are only used during delivery**

[isOvenTriggered()](https://github.com/mdrahmed/txt_training_factory/blob/1ed18ad3cbdb572e658717b17052ecd8f3c344dc/TxtSmartFactoryLib/src/TxtMultiProcessingStationRun.cpp#L122) - This condition is checking the status of over at first when the `vgr` is using the `mpo` for delivering a workpiece.

[isEndConveyorBeltTriggered()](https://github.com/mdrahmed/txt_training_factory/blob/1ed18ad3cbdb572e658717b17052ecd8f3c344dc/TxtSmartFactoryLib/src/TxtMultiProcessingStationRun.cpp#L262) - It is checking the conveyor belt. The conveyor belt which is used to send the workpiece to the sld. 

### SLD
[isColorSensorTriggered()](https://github.com/mdrahmed/txt_training_factory/blob/1ed18ad3cbdb572e658717b17052ecd8f3c344dc/TxtSmartFactoryLib/src/TxtSortingLineRun.cpp#L136) - Checking if color sensor is triggered.

[readColorValue() < detectedColorValue](https://github.com/mdrahmed/txt_training_factory/blob/1ed18ad3cbdb572e658717b17052ecd8f3c344dc/TxtSmartFactoryLib/src/TxtSortingLineRun.cpp#L166) - reading the color value.

[getDetectedColor()](https://github.com/mdrahmed/txt_training_factory/blob/1ed18ad3cbdb572e658717b17052ecd8f3c344dc/TxtSmartFactoryLib/src/TxtSortingLineRun.cpp#L196) - Based on the color it is checking which workpiece to eject.

[getDetectedColor()](https://github.com/mdrahmed/txt_training_factory/blob/master/TxtSmartFactoryLib/src/TxtSortingLine.cpp#L129) - This function is used to detect the colors based on predefined checks.

[getLastColor()](https://github.com/mdrahmed/txt_training_factory/blob/master/TxtSmartFactoryLib/src/TxtSortingLine.cpp#L111) - This function is also getting the last color based on the checks which is later used here in this condition - [if (dps.getLastColor() == WP_TYPE_NONE)](https://github.com/mdrahmed/txt_training_factory/blob/1ed18ad3cbdb572e658717b17052ecd8f3c344dc/TxtSmartFactoryLib/src/TxtVacuumGripperRobotRun.cpp#L535)
