import { iVehicleInfo } from "@/types/BasicTypes";
import { buildStyles, CircularProgressbar, CircularProgressbarWithChildren } from "react-circular-progressbar";

type TypeClassic = {
  veh: iVehicleInfo;
};

const SemiCircle = ({ veh }: TypeClassic) => {
  return (
    <div className="veh-hud-semi-circle 4k:-translate-x-12" style={{ width: 260, height: 140, marginBottom: -62 }}>
      <svg style={{ position: "absolute", width: 0, height: 0 }}>
        <defs>
          <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="100%">
            <stop offset="0%" stopColor="#FF4163" />
            <stop offset="100%" stopColor="#FF013D " />
          </linearGradient>
        </defs>
      </svg>
      <CircularProgressbarWithChildren
        className="z-20 relative"
        circleRatio={0.34}
        value={veh.speed}
        maxValue={160}
        strokeWidth={2.5}
        styles={buildStyles({
          rotation: 0.75,
          strokeLinecap: "butt",
          trailColor: "rgba(0,0,0,.4)",
          pathColor: "rgba(255, 255, 255)",
        })}
      >
        <div
          className="absolute top-0 h-1/2 w-full bg-cover z-10 opacity-35"
          style={{
            backgroundImage: "url(images/vehicle_hud/semi_circle_blur.png)",
          }}
        ></div>
        <CircularProgressbar
          className="relative z-20"
          value={veh.fuel.level}
          counterClockwise
          circleRatio={0.15}
          strokeWidth={2.5}
          styles={buildStyles({
            trailColor: "rgba(0, 0, 0, .4)",
            pathColor: "#FFA928",
            rotation: 0.25,
            strokeLinecap: "butt",
          })}
        />
        <div
          className="absolute"
          style={{
            width: "90%",
          }}
        >
          <CircularProgressbarWithChildren
            value={veh.rpm}
            maxValue={0.75}
            minValue={0.25}
            circleRatio={0.39}
            strokeWidth={12}
            styles={buildStyles({
              trailColor: "rgba(0, 0, 0, .4)",
              pathColor: "url(#gradient)",
              rotation: 0.75,
              strokeLinecap: "butt",
              pathTransitionDuration: 0.3,
            })}
          >
            <CircularProgressbar
              value={veh.rpm}
              maxValue={1.0}
              minValue={0.75}
              strokeWidth={12}
              circleRatio={0.1}
              styles={buildStyles({
                trailColor: "rgba(0, 0, 0, .4)",
                pathColor: "#C4FF48",
                rotation: 0.15,
                strokeLinecap: "butt",
                pathTransitionDuration: 0.6,
              })}
            />
            <div className="absolute z-20" style={{ width: "70%" }}>
              <div className="absolute bottom-0">
                <img src="images/vehicle_hud/semi_circle_left_elp.svg" alt="left_elp" />
              </div>
              <div className="absolute bottom-0 right-0">
                <img src="images/vehicle_hud/semi_circle_right_elp.svg" alt="right_elp" />
              </div>
              <div className="absolute bottom-0 left-1/2 -translate-x-1/2" style={{ width: "90%" }}>
                <img src="images/vehicle_hud/semi_circle_bg.png" alt="semi_circle_bg" />
                <div className="absolute bottom-1/2 translate-y-1/4 left-1/2 -translate-x-1/2">
                  <div
                    className="text-transparent grt-ozel"
                    style={{
                      background: "linear-gradient(180deg, #FFF 0%, #999 100%)",
                    }}
                  >
                    <h1
                      className="font-bold font-microgramma-d-extended"
                      style={{
                        fontSize: 32,
                      }}
                    >
                      {veh.speed}
                    </h1>
                  </div>
                  <div
                    className="absolute -bottom-1.5 left-1/2 -translate-x-1/2 grt-ozel"
                    style={{
                      background: "linear-gradient(180deg, #FFF 0%, #999 100%)",
                    }}
                  >
                    <h1 className="text-xs font-bold">{veh.kmH ? "KMH" : "MPH"}</h1>
                  </div>
                </div>
                <div className="absolute bottom-0 flex items-center justify-center gap-5 w-full">
                  <img width={16} src="images/icons/vehicle_spot.svg" alt="vehicle_spot" style={{ opacity: veh.isLightOn ? 1 : 0.15 }} />
                  <img width={16} src="images/icons/seatbelt.svg" alt="seatbelt" style={{ opacity: veh.isSeatbeltOn ? 1 : 0.15 }} />
                </div>
                <img className="absolute bottom-0 w-full z-10" src="images/vehicle_hud/semi_circle_bottom_hr.png" />
              </div>
            </div>
          </CircularProgressbarWithChildren>
        </div>
      </CircularProgressbarWithChildren>
    </div>
  );
};

export default SemiCircle;
