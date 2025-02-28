import { BarStyleType } from "@/types/BasicTypes";
import Circle from "./Circle";
import Zarg from "./Zarg";
import Classic from "./Classic";
import Hexagon from "./Hexagon";
import GrtPremium from "./GrtPremium";
import Square from "./Square";
import WaveC from "./Wave";
import Universal from "./Universal";
import WaveH from "./WaveH";
import ZargM from "./ZargM";
import HexagonW from "./HexagonW";

export interface ProgressBarProps {
  occupancy: number;
  trackColor?: string;
  progressColor?: string;
  strokeWidth?: number;
  transitionSpeed?: number;
  children?: React.ReactNode;
  shape?: BarStyleType;
  [key: string]: any;
}

const ProgressBar: React.FC<ProgressBarProps> = ({ shape = "circle", occupancy = 0, progressColor = "#919191", trackColor = "#212121", strokeWidth, children, ...props }) => {
  const shapeComponents: { [index: string]: React.FC<ProgressBarProps> } = {
    circle: Circle,
    zarg: Zarg,
    classic: Classic,
    "hexagon-w": HexagonW,
    hexagon: Hexagon,
    "grt-premium": GrtPremium,
    square: Square,
    "wave-c": WaveC,
    "wave-h": WaveH,
    universal: Universal,
    "zarg-m": ZargM,
  };

  const ShapeComponent = shapeComponents[shape];
  if (!ShapeComponent) {
    return <></>;
  }

  return (
    <div
      className="progressbar"
      style={{
        width: "100%",
        height: "100%",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        position: "relative",
        overflow: "hidden",
      }}
    >
      <ShapeComponent occupancy={occupancy} strokeWidth={strokeWidth} trackColor={trackColor} progressColor={progressColor} {...props}>
        {children}
      </ShapeComponent>
    </div>
  );
};

export default ProgressBar;
