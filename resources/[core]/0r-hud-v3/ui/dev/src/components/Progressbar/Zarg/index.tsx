import { BarProps } from "@/types/BasicTypes";
import { useEffect, useRef, useState } from "react";

const Zarg = ({ children, occupancy, progressColor = "#2B2B2B", strokeWidth = 8 }: BarProps) => {
  const clampedOccupancy = Math.min(Math.max(occupancy, 0), 100);
  const progressRef = useRef<SVGCircleElement | null>(null);
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

  return (
    <>
      <div className="absolute inset-0 flex items-center justify-center z-10">{children}</div>
      <div className="absolute inset-0 z-0 bg-[#0000004d] opacity-85 rounded-full"></div>
      <svg className="z-10" width="100%" height="100%" viewBox="0 0 115 115">
        <path d="M 57.531845,8.532482 A 48.999363,48.999363 0 0,1 106.53121,57.531845 A 48.999363,48.999363 0 0,1 57.531845,106.53121 A 48.999363,48.999363 0 0,1 8.532482,57.531845 A 48.999363,48.999363 0 0,1 57.531845,8.532482" stroke="#FFFFFF0F" strokeWidth={strokeWidth} fill="none" />
        <path
          className="progress"
          ref={progressRef}
          d="M 57.531845,8.532482 A 48.999363,48.999363 0 0,1 106.53121,57.531845 A 48.999363,48.999363 0 0,1 57.531845,106.53121 A 48.999363,48.999363 0 0,1 8.532482,57.531845 A 48.999363,48.999363 0 0,1 57.531845,8.532482"
          fill="none"
          stroke={progressColor}
          strokeWidth={strokeWidth}
          strokeLinecap="square"
          strokeLinejoin="inherit"
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
export default Zarg;
