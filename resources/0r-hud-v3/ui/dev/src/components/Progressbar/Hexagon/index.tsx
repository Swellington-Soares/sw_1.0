import { BarProps } from "@/types/BasicTypes";
import { useEffect, useRef, useState } from "react";

const Hexagon = ({ children, occupancy, progressColor = "#2B2B2B", strokeWidth = 8 }: BarProps) => {
  const clampedOccupancy = Math.min(Math.max(occupancy, 0), 100);
  const progressRef = useRef<SVGPathElement | null>(null);
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

  const outerHexagonPath = "M 50 0 L 95 25 L 95 75 L 50 100 L 5 75 L 5 25 Z";
  const innerHexagonPath = "M 50 14 L 83 32 L 83 68 L 50 86 L 17 68 L 17 32 Z";

  return (
    <>
      <div className="absolute inset-0 flex items-center justify-center z-10 scale-90">{children}</div>

      <svg className="absolute z-0" width="100%" height="100%" viewBox="-5 -5 110 110">
        <defs>
          <clipPath id="innerHexClip">
            <path d={innerHexagonPath} />
          </clipPath>
        </defs>
        <rect x="0" y="0" width="100" height="100" fill={progressColor} clipPath="url(#innerHexClip)" opacity={0.75} />
      </svg>

      <svg className="z-10" width="100%" height="100%" viewBox="-5 -5 110 110">
        <path d={outerHexagonPath} stroke={"rgba(0,0,0,.4)"} strokeWidth={strokeWidth} fill="none" />
        <path
          className="progress"
          ref={progressRef}
          d={outerHexagonPath}
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

export default Hexagon;
