import { BarProps } from "@/types/BasicTypes";
import { hexToRgba } from "@/utils/misc";

const Universal = ({ example, occupancy, progressColor = "#2B2B2B", children }: BarProps) => {
  const clampedOccupancy = Math.min(Math.max(occupancy, 0), 100);
  return (
    <>
      <div
        className="w-full h-full shrink-0 border flex items-center justify-center relative rounded overflow-hidden"
        style={{
          borderColor: "rgba(255, 255, 255, 0.1)",
          background: "rgba(0,0,0,.5)",
        }}
      >
        <div className="relative z-10 w-full h-full flex items-center justify-center">{children}</div>
        <div
          hidden={example}
          className="absolute w-full overflow-hidden bottom-0"
          style={{
            height: `${clampedOccupancy}%`,
            backgroundColor: hexToRgba(progressColor, 0.75),
            transition: `height .3s linear`,
          }}
        ></div>
      </div>
    </>
  );
};
export default Universal;
