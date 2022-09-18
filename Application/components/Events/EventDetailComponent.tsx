import { NextComponentType } from "next";
import EventDef from "../../interface/EventDef";

const EventDetailComponent: NextComponentType<EventDef> = (props) => {
  return (
    <div className="p-6 max-w-sm bg-white rounded-lg border border-gray-200 shadow-md dark:bg-gray-800 dark:border-gray-700 h-44 overflow-hidden m-8 w-1/4"></div>
  );
};

export default EventDetailComponent;
