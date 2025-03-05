import { iVehicleInfo } from "@/types/BasicTypes";
import { buildStyles, CircularProgressbarWithChildren } from "react-circular-progressbar";
import RadialSeparators from "../RadialSeparators";
import useData from "@/hooks/useData";

type TypeClassic = {
  veh: iVehicleInfo;
};

const NoCarClasses = [14, 15, 16];

const GrtTwo = ({ veh }: TypeClassic) => {
  const { Compass } = useData();
  const isVehPlane = [15, 16].includes(veh.veh_class);
  const isVehBoat = [14].includes(veh.veh_class);
  const isVehCar = ![14, 15, 16].includes(veh.veh_class);
  const { heading } = Compass;

  return (
    <div className="veh-hud-grt-two translate-y-8 4k:-translate-y-4 4k:-translate-x-8" style={{ width: 230 }}>
      <svg style={{ position: "absolute", width: 0, height: 0 }}>
        <defs>
          <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="white" />
            <stop offset="100%" stopColor="#0B73EE" />
          </linearGradient>
        </defs>
      </svg>
      <CircularProgressbarWithChildren
        className="relative z-10"
        circleRatio={0.75}
        value={veh.rpm}
        maxValue={1.75}
        minValue={0.15}
        strokeWidth={2.25}
        styles={buildStyles({
          rotation: 0.625,
          trailColor: "rgba(0, 0, 0, .4)",
          pathColor: "white",
          strokeLinecap: "butt",
        })}
      >
        <div className="absolute" style={{ width: "90%" }}>
          <CircularProgressbarWithChildren
            className="overflow-hidden"
            value={veh.speed}
            circleRatio={0.75}
            maxValue={160}
            strokeWidth={4}
            styles={buildStyles({
              rotation: 0.625,
              trailColor: "rgba(0, 0, 0, .4)",
              pathColor: "url(#gradient)",
              strokeLinecap: "butt",
            })}
          >
            <div>
              <CircularProgressbarWithChildren
                circleRatio={0.025}
                value={veh.fuel.level}
                minValue={75}
                maxValue={100}
                strokeWidth={4}
                styles={buildStyles({
                  trailColor: "rgba(0, 0, 0, .4)",
                  strokeLinecap: "butt",
                  rotation: 0.405,
                  pathColor: "white",
                })}
                counterClockwise
              >
                <CircularProgressbarWithChildren
                  circleRatio={0.025}
                  value={veh.fuel.level}
                  minValue={50}
                  maxValue={74}
                  strokeWidth={4}
                  styles={buildStyles({
                    trailColor: "rgba(0, 0, 0, .4)",
                    strokeLinecap: "butt",
                    rotation: 0.435,
                    pathColor: "white",
                  })}
                  counterClockwise
                >
                  <CircularProgressbarWithChildren
                    circleRatio={0.025}
                    value={veh.fuel.level}
                    minValue={25}
                    maxValue={49}
                    strokeWidth={4}
                    styles={buildStyles({
                      trailColor: "rgba(0, 0, 0, .4)",
                      strokeLinecap: "butt",
                      rotation: 0.465,
                      pathColor: "white",
                    })}
                    counterClockwise
                  >
                    <CircularProgressbarWithChildren
                      circleRatio={0.025}
                      value={veh.fuel.level}
                      minValue={0}
                      maxValue={24}
                      strokeWidth={4}
                      styles={buildStyles({
                        trailColor: "rgba(0, 0, 0, .4)",
                        strokeLinecap: "butt",
                        rotation: 0.495,
                        pathColor: "white",
                      })}
                      counterClockwise
                    >
                      <div className="absolute bottom-0 mr-7 -mb-2 -rotate-12">
                        <img src="images/vehicle_hud/grt_two_fuel.svg" alt="grt_two_fuel" />
                      </div>
                    </CircularProgressbarWithChildren>
                  </CircularProgressbarWithChildren>
                </CircularProgressbarWithChildren>
              </CircularProgressbarWithChildren>
            </div>
            <RadialSeparators
              circleRatio={0.65}
              rotation={0.69}
              padding={0.92}
              count={20}
              style={{
                background: "rgba(45,45,45,.4)",
                width: 4,
                height: `${4}%`,
              }}
              grtTwo
              color="rgba(0, 255, 240, 0.5)"
              value={veh.speed}
              maxValue={160}
            />
            {isVehPlane && (
              <div className="absolute top-1/2 -translate-y-1/2 scale-90 -z-10">
                <img className="animate-plane-dial" src="images/vehicle_hud/grt_two_plane_bg.svg" alt="plane_bg" />
              </div>
            )}
            {isVehBoat && (
              <img
                className="absolute top-1/2 overflow-hidden rounded-full transition-transform duration-75 -z-10"
                style={{
                  transform: `translateY(-50%) rotate(${heading}deg)`,
                  transformOrigin: "center",
                }}
                src="images/vehicle_hud/grt_two_boat_bg.svg"
                alt="boat_bg"
              />
            )}
            <div
              className="flex flex-col items-center z-10 absolute bottom-1/2 translate-y-1/2"
              style={{
                marginBottom: !NoCarClasses.includes(veh.veh_class) ? 0 : -50,
              }}
            >
              <h1
                className="text-center font-extrabold text-white leading-normal"
                style={{
                  fontSize: !NoCarClasses.includes(veh.veh_class) ? 48 : 36,
                }}
              >
                {veh.speed}
              </h1>
              <h1 className="text-xs font-extrabold text-white text-center -mt-3">{veh.kmH ? "KMH" : "MPH"}</h1>
            </div>
            {isVehCar && (
              <div className="absolute bottom-8 z-10">
                <div className="flex items-center justify-center gap-5">
                  <img width={22} src="images/icons/vehicle_spot.svg" alt="vehicle_spot" style={{ opacity: veh.isLightOn ? 1 : 0.5 }} />
                  <img width={22} src="images/icons/seatbelt.svg" alt="seatbelt" style={{ opacity: veh.isSeatbeltOn ? 1 : 0.5 }} />
                </div>
              </div>
            )}
            <>
              <div
                className="absolute top-1/2 -translate-y-1/2 overflow-hidden rounded-full w-full h-full -z-10"
                style={{
                  backgroundImage: "linear-gradient(180deg, rgba(0, 0, 0, .8) 0.14%, rgba(0, 0, 0, 0.00) 89.89%)",
                }}
              />
            </>
          </CircularProgressbarWithChildren>
        </div>
      </CircularProgressbarWithChildren>
    </div>
  );
};
export default GrtTwo;
