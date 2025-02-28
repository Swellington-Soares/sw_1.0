import { iVehicleInfo } from "@/types/BasicTypes";
import classNames from "classnames";
import { MdElectricBolt } from "react-icons/md";
import { GiGearStick } from "react-icons/gi";

type TypeClassic = {
  veh: iVehicleInfo;
};

const NoCarClasses = [14, 15, 16];

const HudV2 = ({ veh }: TypeClassic) => {
  const { rpm, currentGear, speed, kmH, fuel } = veh;
  return (
    <div className="relative flex justify-between items-end">
      <div>
        <div className="flex flex-col gap-1">
          {!NoCarClasses.includes(veh.veh_class) && (
            <div className="flex items-center gap-3 w-full mb-1">
              <img className="w-5 h-5" src="images/icons/vehicle_spot.svg" alt="vehicle_spot" style={{ opacity: veh.isLightOn ? 1 : 0.15 }} />
              <img hidden={veh.isSeatbeltOn} className="w-5 h-5" src="images/icons/seatbelt.svg" alt="seatbelt" />
            </div>
          )}
          <div>
            <div className="flex items-center justify-between gap-1">
              <div className="h-[56px] mb-1 py-1 px-2 border border-[#C4FF48] bg-[#C4FF48] shadow-[#C4FF48] shadow-[0px_0px_4px_0px]">
                <div className="flex flex-col items-center justify-center">
                  <h1 className="text-[#272727] font-bold text-center text-lg">{currentGear}</h1>
                  <GiGearStick className="text-[#272727]" />
                </div>
              </div>
              <div className="h-[56px] bg-black/40 rounded-sm mb-1 px-2 py-1 relative">
                <div className="absolute right-0.5 top-0">
                  <h1 className="text-white/60 text-[9px] font-semibold font-[inherit] float-right">{kmH ? "KMH" : "MPH"}</h1>
                </div>
                <h1 className={`text-5xl tracking-wider speed ${speed === 0 ? "text-white/60" : "text-white"}`}>
                  {Array.from((speed || 0).toString().padStart(3, "0")).map((digit, index) => (
                    <span key={index} className={speed === 0 ? "text-white/60" : index < 3 - speed?.toString().length ? "text-white/60" : ""}>
                      {digit}
                    </span>
                  ))}
                </h1>
              </div>
            </div>
          </div>
          <div className="mt-1">
            <ul className="flex justify-between">
              {[...Array(18)].map((_, i) => (
                <li
                  key={i}
                  className={classNames(
                    "w-1 h-6 bg-[#2a2f30] transition-[color,transform_.5s] duration-200",
                    {
                      "!bg-[#C4FF48] shadow-[#C4FF48] shadow-[0px_0px_2px_0px] animate-rpm": i < 14 && i < Math.round(rpm * 18),
                    },
                    {
                      "!bg-[#FFC148] shadow-[#FFC148] shadow-[0px_0px_2px_0px] animate-rpm": i >= 14 && i < 16 && i < Math.round(rpm * 18),
                    },
                    {
                      "!bg-[#FF9548] shadow-[#FF9548] shadow-[0px_0px_2px_0px] animate-rpm": i >= 15 && i < 16 && i < Math.round(rpm * 18),
                    },
                    {
                      "!bg-[#FF4848] shadow-[#FF4848] shadow-[0px_0px_2px_0px] animate-rpm animate-rpmbounce": i >= 16 && i < Math.round(rpm * 18),
                    },
                    {
                      "delay-500": i == 18 && i <= Math.round(rpm * 18),
                    }
                  )}
                />
              ))}
            </ul>
          </div>
        </div>
      </div>
      <div className="h-[120px]">
        <div className="flex flex-col items-center h-full gap-1">
          <div>
            {fuel?.type == "gasoline" && <img src="images/vehicle_hud/grt_one_fuel.svg" alt="fuel_svg" className="text-white w-6 h-6 relative left-1" />}
            {fuel?.type == "electric" && <MdElectricBolt className="text-white w-4 h-4 relative" />}
          </div>
          <div className="h-full">
            <div className="w-2 h-full bg-gray-700/10 flex flex-col-reverse">
              <div className="bg-white w-2" style={{ height: fuel?.level + "%" }}></div>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
};
export default HudV2;
