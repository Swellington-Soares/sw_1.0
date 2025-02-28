import { iVehicleInfo } from "@/types/BasicTypes";
import { buildStyles, CircularProgressbarWithChildren } from "react-circular-progressbar";

type TypeClassic = {
  veh: iVehicleInfo;
};

const Bmg = ({ veh }: TypeClassic) => {
  const BackgroundImage = "images/vehicle_hud/gmg_bg.png";

  const maxSpeed = 200;
  const maxAngle = 200;
  const rotationAngle = (veh.speed / maxSpeed) * maxAngle - 123;
  const lastAngle = Math.max(-123, Math.min(102, rotationAngle));
  const isVehCar = ![14, 15, 16].includes(veh.veh_class);

  return (
    <div className="veh-hud-bmg relative scale-[.8] translate-y-16 translate-x-10 4k:-translate-y-2 4k:-translate-x-4">
      <CircularProgressbarWithChildren
        strokeWidth={1}
        circleRatio={0.75}
        styles={buildStyles({
          strokeLinecap: "butt",
          pathColor: "white",
          rotation: 0.374,
        })}
        value={100}
      >
        <div className="bg-contain bg-center" style={{ width: "100%", height: "100%", backgroundImage: `url(${BackgroundImage})` }}>
          <div className="absolute flex flex-col top-1/2 -translate-y-1/2 right-5 items-end">
            <h1 className="relative mt-12 text-white font-bold font-microgramma-d-extended" style={{ fontSize: "26px" }}>
              {veh.speed}
              <span className="text-11 ml-0.5">{veh.kmH ? "KMH" : "MPH"}</span>
            </h1>
            <h1 className="relative top-3 right-12 text-white font-bold font-microgramma-d-extended" style={{ fontSize: "46px" }}>
              {veh.currentGear}
            </h1>
          </div>
          <div className="absolute top-1/2 -translate-y-1/2 -mt-6 left-1/2 -translate-x-1/2 -ml-11">
            <svg
              style={{
                transform: `rotate(${lastAngle}deg)`,
                transformOrigin: "bottom right",
                transition: "transform 0.15s linear",
              }}
              xmlns="http://www.w3.org/2000/svg"
              width="87"
              height="57"
              viewBox="0 0 87 57"
              fill="none"
            >
              <path d="M1.385 1.06516L2.4414 0.989703C2.6322 0.976075 2.82249 1.02233 2.98574 1.12201L85.6915 51.6224C86.1368 51.8943 86.2666 52.4822 85.9772 52.9164L83.9463 55.9627C83.6679 56.3802 83.1061 56.4972 82.6842 56.2256L0.895387 3.56083C0.613059 3.37904 0.452377 3.05772 0.476301 2.72278L0.53391 1.91625C0.566473 1.46038 0.929125 1.09772 1.385 1.06516Z" fill="#EE0826" />
              <path d="M82.2853 52.6678L81.9822 52.9709C81.942 53.0111 81.8784 53.0157 81.8329 52.9816C81.7302 52.9045 81.5982 53.0294 81.6694 53.1363L82.7736 54.7926C82.9497 55.0568 83.3354 55.064 83.5213 54.8066L84.5431 53.3918C84.858 52.9557 84.7327 52.3436 84.2718 52.0664L1.35547 2.19531L82.173 51.7188C82.5085 51.9244 82.5635 52.3896 82.2853 52.6678Z" fill="#EE6908" />
            </svg>
          </div>
        </div>
      </CircularProgressbarWithChildren>

      {isVehCar && (
        <div className="absolute -bottom-3 flex items-center justify-center gap-5">
          <img width={24} src="images/icons/vehicle_spot.svg" alt="vehicle_spot" style={{ opacity: veh.isLightOn ? 1 : 0.5 }} />
          <img width={24} src="images/icons/seatbelt.svg" alt="seatbelt" style={{ opacity: veh.isSeatbeltOn ? 1 : 0.5 }} />
        </div>
      )}
    </div>
  );
};

export default Bmg;
