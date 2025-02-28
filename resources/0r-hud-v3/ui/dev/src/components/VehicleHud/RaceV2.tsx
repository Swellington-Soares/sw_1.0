import { iVehicleInfo } from "@/types/BasicTypes";
import { buildStyles, CircularProgressbar, CircularProgressbarWithChildren } from "react-circular-progressbar";

type TypeClassic = {
  veh: iVehicleInfo;
};

const NoCarClasses = [14, 15, 16];

const RaceV2 = ({ veh }: TypeClassic) => {
  const { rpm, speed, kmH, fuel } = veh;
  return (
    <div className="relative translate-y-20 4k:translate-y-10">
      <div className="w-16 absolute bottom-12 -left-16">
        <CircularProgressbarWithChildren
          value={0}
          strokeWidth={16}
          circleRatio={0.5}
          styles={buildStyles({
            rotation: 0.6,
            trailColor: "rgba(26, 49, 16, 0.5)",
            pathColor: "#C4FF48",
          })}
        >
          <div style={{ width: "92%" }}>
            <CircularProgressbar
              value={fuel.level}
              strokeWidth={10}
              circleRatio={0.5}
              styles={buildStyles({
                rotation: 0.6,
                trailColor: "transparent",
                pathColor: "#C4FF48",
                textColor: "white",
              })}
            />
            <div className="absolute top-2 right-0 -translate-x-4 translate-y-1/2">
              <h1 className="font-medium font-yorkbailehill text-white">
                {fuel.level.toFixed(0)}
                {"%"}
              </h1>
            </div>
          </div>
        </CircularProgressbarWithChildren>
        <div className="absolute bottom-7 -left-6 -rotate-6">
          <img className="w-6" src="images/vehicle_hud/grt_one_fuel.svg" alt="fuel-gas" />
        </div>
      </div>
      <div className="w-48">
        <CircularProgressbarWithChildren
          className="relative"
          value={rpm * 100}
          circleRatio={0.65}
          strokeWidth={3.5}
          styles={buildStyles({
            rotation: 0.66,
            trailColor: "transparent",
            pathColor: rpm < 0.85 ? "#C4FF48" : "#FF013D",
          })}
        >
          <div style={{ width: "91%" }}>
            <CircularProgressbar
              value={100}
              strokeWidth={2}
              circleRatio={0.66}
              styles={buildStyles({
                rotation: 0.67,
                trailColor: "transparent",
                pathColor: "#dfe4e3",
              })}
            />
          </div>
          <div className="absolute">
            <div className="flex flex-col items-center mb-4">
              <h1 className="font-bold text-white" style={{ fontSize: 40 }}>
                {speed}
              </h1>
              <h1 className="text-white font-bold -mt-3">{kmH ? "KMH" : "MPH"}</h1>
            </div>
          </div>
          {!NoCarClasses.includes(veh.veh_class) && (
            <div className="absolute bottom-10 w-full flex items-center justify-center gap-2 left-1/2 -translate-x-1/2">
              <img width={20} src="images/icons/vehicle_spot.svg" alt="vehicle_spot" style={{ opacity: veh.isLightOn ? 1 : 0.15 }} />
              <img width={20} src="images/icons/seatbelt.svg" alt="seatbelt" style={{ opacity: veh.isSeatbeltOn ? 1 : 0.15 }} />
            </div>
          )}
        </CircularProgressbarWithChildren>
      </div>
    </div>
  );
};
export default RaceV2;
