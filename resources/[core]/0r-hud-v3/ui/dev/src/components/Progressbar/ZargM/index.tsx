import { BarProps } from "@/types/BasicTypes";

import { CircularProgressbar, buildStyles } from "react-circular-progressbar";
import "react-circular-progressbar/dist/styles.css";

const ZargM = ({
  occupancy,
  progressColor = "#FF5F5F",
  rotation = 0,
  counterClockwise = false,
}: BarProps) => {
  const clampedOccupancy = Math.min(Math.max(occupancy, 0), 100);
  return (
    <>
      <CircularProgressbar
        value={clampedOccupancy}
        circleRatio={0.25}
        styles={buildStyles({
          rotation: rotation,
          trailColor: "rgba(0, 0, 0, 0.5)",
          pathColor: progressColor,
        })}
        strokeWidth={2.5}
        counterClockwise={counterClockwise}
      />
    </>
  );
};

export default ZargM;
