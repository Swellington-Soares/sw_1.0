import { BarProps } from "@/types/BasicTypes";

const HexagonW = ({ children, occupancy, progressColor = "#2B2B2B", strokeWidth = 8 }: BarProps) => {
  const outerHexagonPath = "M 50 0 L 95 25 L 95 75 L 50 100 L 5 75 L 5 25 Z";
  const innerHexagonPath = "M 50 14 L 83 32 L 83 68 L 50 86 L 17 68 L 17 32 Z";

  const clampedOccupancy = Math.min(Math.max(occupancy, 0), 100);

  return (
    <>
      <div className="absolute inset-0 flex items-center justify-center z-10">{children}</div>
      <svg width="100%" height="100%" viewBox="-5 -5 110 110">
        <defs>
          <clipPath id="innerHexClip">
            <path d={innerHexagonPath} />
          </clipPath>
        </defs>
        <path d={outerHexagonPath} strokeWidth={strokeWidth} fill="none" stroke={progressColor} />
        <path d={innerHexagonPath} strokeWidth={strokeWidth / 1.5} fill="none" stroke={progressColor} />
        <rect
          x="0"
          y={100 - (clampedOccupancy / 100) * 100}
          width="100"
          height={(clampedOccupancy / 100) * 100}
          fill={progressColor}
          clipPath="url(#innerHexClip)"
          opacity={0.8}
          style={{
            transition: `y .3s linear, height .3s linear`,
          }}
        />
        <rect x="0" y="0" width="100" height={100} fill={progressColor} clipPath="url(#innerHexClip)" opacity={0.3} />
      </svg>
    </>
  );
};

export default HexagonW;
