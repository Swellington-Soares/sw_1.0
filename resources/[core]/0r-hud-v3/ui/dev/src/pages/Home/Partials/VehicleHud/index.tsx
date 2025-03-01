import useData from "@/hooks/useData";
import { DragDropContainer } from "react-drag-drop-container-typescript";

import ClassicOld from "@/components/VehicleHud/ClassicOld";
import TimeBomb from "@/components/VehicleHud/TimeBomb";
import SemiCircle from "@/components/VehicleHud/SemiCircle";
import GrtOne from "@/components/VehicleHud/GrtOne";
import GrtTwo from "@/components/VehicleHud/GrtTwo";
import Globe from "@/components/VehicleHud/Globe";
import { FaLocationCrosshairs } from "react-icons/fa6";
import HudV2 from "@/components/VehicleHud/HudV2";
import RaceV2 from "@/components/VehicleHud/RaceV2";
import Bmg from "@/components/VehicleHud/Bmg";
import Gmg from "@/components/VehicleHud/Gmg";

export const VehicleHud = () => {
  const { VehicleInfo, HudStyle, onChangeHudPositions, isEditorOpen } = useData();

  const renderHud = () => {
    switch (HudStyle.vehicle_hud_style) {
      case 1:
        return <ClassicOld veh={VehicleInfo} />;
      case 2:
        return <TimeBomb veh={VehicleInfo} />;
      case 3:
        return <GrtOne veh={VehicleInfo} />;
      case 4:
        return <GrtTwo veh={VehicleInfo} />;
      case 5:
        return <Bmg veh={VehicleInfo} />;
      case 6:
        return <Gmg veh={VehicleInfo} />;
      case 7:
        return <Globe veh={VehicleInfo} />;
      case 8:
        return <SemiCircle veh={VehicleInfo} />;
      case 9:
        return <HudV2 veh={VehicleInfo} />;
      case 10:
        return <RaceV2 veh={VehicleInfo} />;
      default:
        return <ClassicOld veh={VehicleInfo} />;
    }
  };

  const { positions } = VehicleInfo;

  const posStyle = {} as any;
  if (positions.x) {
    posStyle.left = positions.x;
  } else {
    posStyle.right = 32;
  }
  if (positions.y) {
    posStyle.top = positions.y;
  } else {
    posStyle.bottom = 52;
  }

  const handleDragEnd = (key: string, x: number, y: number) => {
    onChangeHudPositions(key, x, y);
  };

  const NoHudClasses = [13, 21];

  return (
    !!VehicleInfo.entity &&
    !NoHudClasses.includes(VehicleInfo.veh_class) && (
      <div className="absolute select-none" style={posStyle}>
        <DragDropContainer
          noDragging={!isEditorOpen}
          dragElemOpacity={0.75}
          onDragEnd={(_, __, x, y) => {
            handleDragEnd("vehicle_info", x, y);
          }}
        >
          {isEditorOpen && (
            <button className="absolute -left-5 -top-6 z-10 p-2 rounded-full border border-white/15 bg-white/15">
              <FaLocationCrosshairs />
            </button>
          )}
          <div className="mr-10 4k:scale-150">{renderHud()}</div>
        </DragDropContainer>
      </div>
    )
  );
};
