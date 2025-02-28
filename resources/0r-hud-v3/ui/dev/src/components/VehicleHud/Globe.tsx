import { iVehicleInfo } from "@/types/BasicTypes";
import { buildStyles, CircularProgressbarWithChildren } from "react-circular-progressbar";
import RadialSeparators from "../RadialSeparators";
import useData from "@/hooks/useData";

type TypeClassic = {
  veh: iVehicleInfo;
};

const Globe = ({ veh }: TypeClassic) => {
  const { Compass } = useData();
  const iGear = typeof veh.currentGear == "string" ? (veh.currentGear.toLocaleLowerCase() == "r" ? 1 : 0) : veh.currentGear;

  const isVehPlane = [15, 16].includes(veh.veh_class);
  const isVehCar = ![14, 15, 16].includes(veh.veh_class);
  const { heading } = Compass;

  return (
    <div className="veh-hud-globe -translate-x-3 translate-y-12 4k:translate-y-0 4k:-translate-x-10" style={{ width: 240, height: 180 }}>
      <CircularProgressbarWithChildren
        value={veh.fuel.level}
        circleRatio={0.2}
        maxValue={100}
        strokeWidth={2}
        styles={buildStyles({
          rotation: 0.335,
          trailColor: "rgba(0, 0, 0, .4)",
          pathColor: "#FFB800",
          strokeLinecap: "butt",
        })}
        counterClockwise
      >
        <div className="absolute" style={{ width: "93%" }}>
          <CircularProgressbarWithChildren
            circleRatio={0.6725}
            value={veh.rpm + iGear}
            maxValue={6}
            strokeWidth={2}
            styles={buildStyles({
              rotation: 0.665,
              strokeLinecap: "butt",
              trailColor: "rgba(255, 255, 255, .1)",
              pathColor: "rgba(255, 255, 255, 1)",
            })}
          >
            <>
              <RadialSeparators
                circleRatio={0.74}
                rotation={0.6835}
                padding={0.85}
                count={7}
                style={{
                  fontSize: 16,
                  fontWeight: "500",
                  zIndex: 10,
                }}
                number={0}
                globe
              />
            </>
            <div className="mb-12 z-10 w-full">
              {isVehCar ? (
                <h1 className="font-bold font-microgramma-d-extended text-center" style={{ fontSize: 46 }}>
                  {veh.speed}
                </h1>
              ) : isVehPlane ? (
                <div className="scale-90">
                  <img className="animate-plane-dial -z-10 opacity-75" src="images/vehicle_hud/globe_plane_bg.svg" alt="plane_bg" />
                </div>
              ) : (
                <img
                  className="rounded-full transition-transform duration-75 -z-10 absolute left-1/2"
                  style={{
                    transform: `translate(-50%, -50%) rotate(${heading}deg)`,
                    transformOrigin: "center",
                  }}
                  src="images/vehicle_hud/globe_boat_bg.svg"
                  alt="globe_boat_bg"
                />
              )}
            </div>
            <>
              <div className="absolute w-[290px] h-[290px] bg-center bg-cover" style={{ backgroundImage: "url(images/vehicle_hud/globe_bg.png)" }}></div>
            </>
          </CircularProgressbarWithChildren>
        </div>
      </CircularProgressbarWithChildren>
      <>
        <div className="absolute bottom-0 w-full px-8">
          <img src="images/vehicle_hud/globe_bottom_hr.png" alt="globe_bottom" />
        </div>
        <div
          className="absolute bottom-0 left-1/2 -translate-x-1/2 flex items-end justify-center"
          style={{
            height: 78,
            width: "80%",
            background: "radial-gradient(59.4% 58.09% at 50% 66.18%, rgba(255, 255, 255, 0.05) 0%, rgba(255, 255, 255, 0.00) 100%)",
            clipPath: "polygon(50% 0%, 0% 100%, 100% 100%)",
          }}
        >
          {isVehCar ? (
            <div className="flex items-center justify-center gap-5 mb-2">
              <img width={18} src="images/icons/vehicle_spot.svg" alt="vehicle_spot" style={{ opacity: veh.isLightOn ? 1 : 0.5 }} />
              <img width={18} src="images/icons/seatbelt.svg" alt="seatbelt" style={{ opacity: veh.isSeatbeltOn ? 1 : 0.5 }} />
            </div>
          ) : (
            <div className="relative z-10 mb-4">
              <h1 className="font-bold font-microgramma-d-extended" style={{ fontSize: 22.3 }}>
                {veh.speed}
              </h1>
            </div>
          )}
        </div>
      </>
    </div>
  );
};

export default Globe;
