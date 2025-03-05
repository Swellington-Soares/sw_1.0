import useData from "@/hooks/useData";
import { BarProps } from "@/types/BasicTypes";
import { hexToRgba } from "@/utils/misc";
import { useEffect, useState } from "react";

const GrtPremium = ({ example, occupancy, progressColor = "#2B2B2B", children }: BarProps) => {
  const { ClientInfo } = useData();
  const clampedOccupancy = Math.min(Math.max(occupancy, 0), 100);

  const [width, setWidth] = useState<number>(0);

  useEffect(() => {
    setWidth(clampedOccupancy);
  }, [clampedOccupancy]);

  const backgroundStyle =
    ClientInfo.time.gameHours < 9
      ? {
          backgroundImage: `radial-gradient(circle at center, ${hexToRgba(progressColor, 0)} 5%, ${hexToRgba(progressColor, 0.28)} 100%)`,
        }
      : { backgroundColor: "rgba(0,0,0,.25)" };

  return (
    <>
      <div
        className="w-full h-full shrink-0 border-2 flex items-center justify-center relative rounded-lg overflow-hidden"
        style={{
          borderColor: progressColor,
        }}
      >
        <div className="relative z-10 w-full h-full flex items-center justify-center">{children}</div>
        <div className="absolute inset-0 z-0" style={backgroundStyle}></div>
        <div hidden={example} className="absolute bottom-0.5 w-full h-[3px]">
          <div className="w-full h-full flex items-center justify-center px-[3px]">
            <div className="relative bg-black/40 w-full h-full rounded-full overflow-hidden">
              <div
                className="absolute h-full rounded-full"
                style={{
                  backgroundColor: progressColor,
                  width: `${width}%`,
                  transition: "width .3s linear",
                }}
              ></div>
            </div>
          </div>
        </div>
      </div>
    </>
  );
};
export default GrtPremium;
