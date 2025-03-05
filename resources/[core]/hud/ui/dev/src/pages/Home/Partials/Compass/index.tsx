import useData from "@/hooks/useData";
import { useEffect } from "react";
import { gsap } from "gsap";
import "./index.scss";

export const Compass = () => {
  const { Compass, VehicleInfo } = useData();

  useEffect(() => {
    if (Compass.heading) {
      const value = Compass.heading;
      const compassContainer: HTMLElement | null = document.querySelector(".direction .directions");
      if (compassContainer) {
        gsap.to(compassContainer, {
          duration: 0.3,
          attr: { viewBox: `${value - 90} 0 180 1.5` },
          ease: "power1.inOut",
        });
      }
    }
  }, [Compass.heading]);

  return (
    Compass.active &&
    Compass.show &&
    (!Compass.onlyInVehicle || !!VehicleInfo.entity) && (
      <>
        <div id="compass" className="absolute top-0 left-1/2 -translate-x-1/2 select-none 4k:scale-150 4k:translate-y-4">
          <div className="flex flex-col w-full max-w-screen-sm mx-auto items-center compass">
            <div
              className="flex relative justify-center items-end gap-2 bg-white pt-1 pb-1 2k:pb-2 w-full"
              style={{
                background: "linear-gradient(90deg, rgba(25,25,25,0) 0%, rgba(25,25,25,0.3477766106442577) 10%, rgba(25,25,25,0.6026785714285714) 50%, rgba(25,25,25,0.3533788515406162) 90%, rgba(25,25,25,0) 100%)",
              }}
            >
              <div className="street1 w-32 2k:w-40 overflow-hidden">
                <h1 className="text-nowrap text-white/90 whitespace-nowrap">{Compass?.street1}</h1>
              </div>
              <div className="direction relative flex justify-center px-6">
                <div className="triangle-bottom absolute z-50"></div>
                <div className="relative font-medium text-white w-[180px]">
                  <svg className="directions transition-transform h-8 w-full flex pt-5">
                    <text x="0" y="4.5" fill="white" textAnchor="middle">
                      N
                    </text>
                    <text x="360" y="4.5" fill="white" textAnchor="middle">
                      N
                    </text>
                    <text className="side" x="315" y="4.5" fill="white" textAnchor="middle">
                      NW
                    </text>
                    <text className="side" x="-45" y="4.5" fill="white" textAnchor="middle">
                      NW
                    </text>

                    <text className="side" x="45" y="4.5" fill="white" textAnchor="middle">
                      NE
                    </text>
                    <text className="side" x="405" y="4.5" fill="white" textAnchor="middle">
                      NE
                    </text>

                    <text x="90" y="4.5" fill="white" textAnchor="middle">
                      E
                    </text>
                    <text className="side" x="135" y="4.5" fill="white" textAnchor="middle">
                      SE
                    </text>
                    <text x="180" y="4.5" fill="white" textAnchor="middle">
                      S
                    </text>
                    <text className="side" x="225" y="4.5" fill="white" textAnchor="middle">
                      SW
                    </text>
                    <text x="270" y="4.5" fill="white" textAnchor="middle">
                      W
                    </text>
                  </svg>
                </div>
              </div>
              <div className="street2 w-32 2k:w-40 overflow-hidden">
                <h1 className="text-nowrap text-white/90 whitespace-nowrap">{Compass?.street2}</h1>
              </div>
            </div>
          </div>
        </div>
      </>
    )
  );
};
