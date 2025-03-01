import useData from "@/hooks/useData";
import { iVehicleInfo } from "@/types/BasicTypes";
import { fetchNui } from "@/utils/fetchNui";
import classNames from "classnames";
import { useState } from "react";
import { useTranslation } from "react-i18next";
import { ReactSVG } from "react-svg";

const CarControl = () => {
  const { t } = useTranslation();
  const { VehicleInfo, setVehicleInfo } = useData();
  const [isSleep, setSleep] = useState<boolean>(false);
  const [oldUpdatedDoor, setOldUpdatedDoor] = useState<number>();
  const [oldUpdatedSeatIndex, setOldUpdatedSeatIndex] = useState<number>();

  const handleSetVehicleDoor = async (doorIndex: number) => {
    if (!VehicleInfo.entity) return;
    if (oldUpdatedDoor === doorIndex) {
      if (isSleep) return;
      setSleep(true);
    }

    try {
      const result = await fetchNui("nui:setVehicleDoor", doorIndex, {
        success: true,
        state: true,
      });
      if (result.success) {
        const doorStateMap: Record<number, keyof iVehicleInfo> = {
          0: "isFrontLeftDoorOn",
          1: "isFrontRightDoorOn",
          2: "isBackLeftDoorOn",
          3: "isBackRightDoorOn",
          4: "isHoodOn",
          5: "isTrunkOn",
        };

        const doorState = doorStateMap[doorIndex];

        if (doorState) {
          setVehicleInfo((prevHud) => ({
            ...prevHud,
            [doorState]: result.state,
          }));
        } else {
          console.warn(`Unknown door index: ${doorIndex}`);
        }
      }
    } catch (error) {
      console.error("Error while setting vehicle door: ", error);
    } finally {
      setOldUpdatedDoor(doorIndex);
      setTimeout(() => setSleep(false), 500);
    }
  };

  const handleSetVehicleLights = async () => {
    if (!VehicleInfo.entity) return;
    const newBoolean = !VehicleInfo.isLightOn;
    try {
      await fetchNui("nui:setVehicleLights", newBoolean, true);
    } catch (error) {
      console.error("Error while setting vehicle lights: ", error);
    } finally {
      setTimeout(() => setSleep(false), 500);
    }
  };

  const handleSetVehicleGearType = async () => {
    if (!VehicleInfo.entity) return;
    const newState = VehicleInfo.gearType == "auto" ? "manual" : "auto";
    try {
      const result = await fetchNui("nui:setVehicleGearType", newState, true);
      if (result) {
        setVehicleInfo((prevVehicleInfo) => ({
          ...prevVehicleInfo,
          gearType: newState,
        }));
      }
    } catch (error) {
      console.error("Error while setting vehicle gear mode: ", error);
    } finally {
      setTimeout(() => setSleep(false), 500);
    }
  };

  const handleSetPedIntoVehicle = async (seatIndex: number) => {
    if (!VehicleInfo.entity) return;
    if (oldUpdatedSeatIndex == seatIndex) {
      return;
    }
    try {
      const result = await fetchNui("nui:setPedIntoVehicle", seatIndex, true);
      if (result) {
        setVehicleInfo((prevVehicleInfo) => ({
          ...prevVehicleInfo,
          seatIndex: seatIndex,
        }));
      }
    } catch (error) {
      console.error("Error while setting ped into vehicle: ", error);
    } finally {
      setOldUpdatedSeatIndex(seatIndex);
    }
  };

  return (
    <>
      <div className="p-2.5 flex flex-col flex-1 justify-between" style={{ height: 280 }}>
        <div className="grid grid-cols-8 p-[3px] gap-[3px] bg-black/45 rounded">
          <button
            onClick={() => handleSetVehicleDoor(0)}
            className={classNames("flex justify-center items-center transition-opacity hover:opacity-100", {
              "opacity-15": !VehicleInfo.isFrontLeftDoorOn,
              "opacity-100": VehicleInfo.isFrontLeftDoorOn,
            })}
          >
            <img src="images/icons/vehicle_front_door.svg" alt="front_door" />
          </button>
          <button
            onClick={() => handleSetVehicleDoor(2)}
            className={classNames("flex justify-center items-center transition-opacity hover:opacity-100", {
              "opacity-15": !VehicleInfo.isBackLeftDoorOn,
              "opacity-100": VehicleInfo.isBackLeftDoorOn,
            })}
          >
            <img src="images/icons/vehicle_back_door.svg" alt="back_door" />
          </button>
          <button
            onClick={() => handleSetVehicleDoor(4)}
            className={classNames("col-span-2 border rouned-[1px] border-white/10 flex justify-center items-center transition-opacity hover:opacity-100", {
              "opacity-15": !VehicleInfo.isHoodOn,
              "opacity-100": VehicleInfo.isHoodOn,
            })}
            style={{
              background: "radial-gradient(50% 50% at 50% 50%, rgba(255, 255, 255, 0.58) 0%, rgba(153, 153, 153, 0.58) 100%)",
            }}
          >
            <img src="images/icons/vehicle_hood.svg" alt="vehicle_hood" />
          </button>
          <button
            onClick={() => handleSetVehicleDoor(5)}
            className={classNames("col-span-2 border rouned-[1px] border-white/10 flex justify-center items-center transition-opacity hover:opacity-100", {
              "opacity-15": !VehicleInfo.isTrunkOn,
              "opacity-100": VehicleInfo.isTrunkOn,
            })}
            style={{
              background: "radial-gradient(50% 50% at 50% 50%, rgba(255, 255, 255, 0.58) 0%, rgba(153, 153, 153, 0.58) 100%)",
            }}
          >
            <img src="images/icons/vehicle_trunk.svg" alt="vehicle_trunk" />
          </button>
          <button
            onClick={() => handleSetVehicleDoor(1)}
            className={classNames("flex justify-center items-center transition-opacity hover:opacity-100", {
              "opacity-15": !VehicleInfo.isFrontRightDoorOn,
              "opacity-100": VehicleInfo.isFrontRightDoorOn,
            })}
          >
            <img src="images/icons/vehicle_front_door.svg" alt="front_door" />
          </button>
          <button
            onClick={() => handleSetVehicleDoor(3)}
            className={classNames("flex justify-center items-center transition-opacity hover:opacity-100", {
              "opacity-15": !VehicleInfo.isBackRightDoorOn,
              "opacity-100": VehicleInfo.isBackRightDoorOn,
            })}
          >
            <img src="images/icons/vehicle_back_door.svg" alt="back_door" />
          </button>
        </div>
        <div className="flex justify-between items-center gap-2">
          <button onClick={handleSetVehicleLights} className="group relative min-w-7 min-h-7 rounded-[30px] border-2 border-black/45 bg-cover flex items-center justify-center p-1" style={{ backgroundImage: "url(images/icons/ellipse_278.svg)" }}>
            <ReactSVG
              className={classNames("min-w-full min-h-full group-hover:opacity-100", {
                "opacity-100": VehicleInfo.isLightOn,
                "opacity-20": !VehicleInfo.isLightOn,
              })}
              src="images/icons/vehicle_spot.svg"
            ></ReactSVG>
          </button>
          <div>
            <img src="images/core/fiyakali_araba.png" alt="car" />
          </div>
          <div className="rounded-[30px] bg-black/45 p-2.5 flex flex-col gap-4">
            <button
              onClick={handleSetVehicleGearType}
              className={classNames("flex justify-center items-center transition-opacity hover:opacity-100", {
                "opacity-100": VehicleInfo.gearType == "manual",
                "opacity-15": VehicleInfo.gearType != "manual",
              })}
            >
              <img className="w-8" src="images/icons/gear_manual.svg" alt="gear_manual" />
            </button>
            <button
              onClick={handleSetVehicleGearType}
              className={classNames("flex justify-center items-center transition-opacity hover:opacity-100", {
                "opacity-100": VehicleInfo.gearType == "auto",
                "opacity-15": VehicleInfo.gearType != "auto",
              })}
            >
              <img className="w-8" src="images/icons/gear_auto.svg" alt="gear_auto" />
            </button>
          </div>
        </div>
        <div className="w-full flex items-center justify-between">
          <div
            className="flex items-center gap-1 rounded p-1 w-full"
            style={{
              background: "linear-gradient(90deg, rgba(0, 0, 0, 0.45) 0%, rgba(0, 0, 0, 0.00) 100%)",
            }}
          >
            <button
              onClick={() => handleSetPedIntoVehicle(-1)}
              className={classNames("flex justify-center items-center transition-opacity hover:opacity-100", {
                "opacity-15": VehicleInfo.seatIndex != -1,
                "opacity-100": VehicleInfo.seatIndex == -1,
              })}
            >
              <img src="images/icons/vehicle_seat_1.svg" alt="vehicle_seat_1" />
            </button>
            <button
              onClick={() => handleSetPedIntoVehicle(0)}
              className={classNames("flex justify-center items-center transition-opacity hover:opacity-100", {
                "opacity-15": VehicleInfo.seatIndex != 0,
                "opacity-100": VehicleInfo.seatIndex == 0,
              })}
            >
              <img src="images/icons/vehicle_seat_2.svg" alt="vehicle_seat_2" />
            </button>
          </div>
          <h1
            className="text-xs font-bold text-white/25"
            style={{
              textShadow: "0px 3.509px 3.509px rgba(0, 0, 0, 0.25)",
            }}
          >
            {t("seat")}
          </h1>
          <div
            className="flex items-center gap-1 rounded p-1 w-full justify-end"
            style={{
              background: "linear-gradient(-90deg, rgba(0, 0, 0, 0.45) 0%, rgba(0, 0, 0, 0.00) 100%)",
            }}
          >
            <button
              onClick={() => handleSetPedIntoVehicle(1)}
              className={classNames("flex justify-center items-center transition-opacity hover:opacity-100", {
                "opacity-15": VehicleInfo.seatIndex != 1,
                "opacity-100": VehicleInfo.seatIndex == 1,
              })}
            >
              <img src="images/icons/vehicle_seat_3.svg" alt="vehicle_seat_3" />
            </button>
            <button
              onClick={() => handleSetPedIntoVehicle(2)}
              className={classNames("flex justify-center items-center transition-opacity hover:opacity-100", {
                "opacity-15": VehicleInfo.seatIndex != 2,
                "opacity-100": VehicleInfo.seatIndex == 2,
              })}
            >
              <img src="images/icons/vehicle_seat_4.svg" alt="vehicle_seat_4" />
            </button>
          </div>
        </div>
      </div>
    </>
  );
};

export default CarControl;
