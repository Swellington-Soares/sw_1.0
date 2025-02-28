import React from "react";
import _ from "lodash";

interface SeparatorProps {
  turns: number;
  style: React.CSSProperties;
  circleRatio: number;
  padding: number;
  rotation: number;
  [key: string]: any;
}

function Separator({ turns, style, circleRatio, padding, rotation, ...props }: SeparatorProps) {
  const oneTransform = () => {
    return {
      transform: `rotate(${rotation + turns * circleRatio}turn)`,
    };
  };
  const twoTransform = () => {
    if (typeof props.number == "number") {
      return { transform: `rotate(-${rotation + turns * circleRatio}turn)` };
    }
    if (props.grtTwo) {
      if (props.color) {
        if (props.value != undefined) {
          return {};
        }
        return { background: props.color };
      }
      return {};
    }
  };

  return (
    <div
      className="transition"
      style={{
        position: "absolute",
        height: `${100 * (padding || 1)}%`,
        zIndex: 1,
        ...oneTransform(),
      }}
    >
      <div
        style={{
          ...style,
          ...twoTransform(),
        }}
      >
        {props.grtOne && props.number * (props.index + 1)}
        {props.globe && <span style={{ color: props.number + props.index >= 5 ? "#FFB800" : "white" }}>{props.number + props.index}</span>}
      </div>
    </div>
  );
}

interface RadialSeparatorsProps {
  count: number;
  style: React.CSSProperties;
  circleRatio?: number;
  padding?: number;
  rotation?: number;
  [key: string]: any;
}

function RadialSeparators({ count, style, circleRatio = 1, padding = 1, rotation = 1, ...props }: RadialSeparatorsProps) {
  const turns = 1 / count;
  return _.range(count).map((index) => <Separator key={index} turns={index * turns} style={style} circleRatio={circleRatio} padding={padding} rotation={rotation} count={count} index={index} {...props} />);
}

export default RadialSeparators;
