import { BarProps } from "@/types/BasicTypes";
import { hexToRgba } from "@/utils/misc";
import { useEffect, useRef, useState } from "react";

const Classic = ({ children, occupancy, progressColor = "#2B2B2B", strokeWidth = 10 }: BarProps) => {
  const clampedOccupancy = Math.min(Math.max(occupancy, 0), 100);
  const progressRef = useRef<SVGRectElement | null>(null);
  const [pathLength, setPathLength] = useState<number>(0);
  const filledLength = (clampedOccupancy / 100) * pathLength;
  const strokeDashoffsetValue = pathLength - filledLength;

  useEffect(() => {
    if (progressRef.current) {
      requestAnimationFrame(() => {
        if (progressRef.current) {
          const length = progressRef.current.getTotalLength();
          setPathLength(length);
        }
      });
    }
  }, []);

  const backgroundStyle = { backgroundColor: hexToRgba(progressColor, 0.45) };

  return (
    <>
      <div className="absolute inset-0 flex items-center justify-center z-10">
        {children}
        <div className="absolute -z-10" style={{ width: "60%", height: "60%", ...backgroundStyle }}></div>
      </div>

      <svg width="100%" height="100%" viewBox="0 0 115 115">
        <path d="M 56.945618,8.5103502 H 107.49016 V 107.50024 H 8.5002594 V 8.5103502 H 56.945618" stroke="rgba(0,0,0,.4)" strokeWidth={strokeWidth} fill="none" />
        <path
          className="progress"
          ref={progressRef}
          d="M 56.945618,8.5103502 H 107.49016 V 107.50024 H 8.5002594 V 8.5103502 H 56.945618"
          fill="none"
          stroke={progressColor}
          strokeWidth={strokeWidth}
          strokeDasharray={pathLength}
          strokeDashoffset={strokeDashoffsetValue}
          style={{
            transition: `stroke-dashoffset .3s linear`,
          }}
        />
      </svg>
    </>
  );
};

export default Classic;
