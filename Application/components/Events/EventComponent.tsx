import { NextComponentType } from "next";
import EventDef from "../../interface/EventDef";

const EventComponent: NextComponentType<EventDef> = (props) => {
  return (
    <div className="p-6 max-w-sm bg-white rounded-lg border border-gray-200 shadow-md dark:bg-gray-800 dark:border-gray-700 h-44 overflow-hidden m-8 w-1/4">
      <a href={"/event-detail/" + props.address + "/" + props.id}>
        <h5 className="mb-2 text-2xl font-bold tracking-tight text-gray-900 dark:text-white">
          {props.title}
        </h5>
      </a>
      <a
        href={"/event-detail/" + props.address + "/" + props.id}
        className="inline-flex items-center py-2 px-3 text-sm font-medium text-center text-white bg-black rounded-lg hover:opacity-90 focus:ring-4 focus:outline-none my-4"
      >
        Get a Ticket from Event
        <svg
          aria-hidden="true"
          className="ml-2 -mr-1 w-4 h-4"
          fill="currentColor"
          viewBox="0 0 20 20"
          xmlns="http://www.w3.org/2000/svg"
        >
          <path
            fill-rule="evenodd"
            d="M10.293 3.293a1 1 0 011.414 0l6 6a1 1 0 010 1.414l-6 6a1 1 0 01-1.414-1.414L14.586 11H3a1 1 0 110-2h11.586l-4.293-4.293a1 1 0 010-1.414z"
            clip-rule="evenodd"
          ></path>
        </svg>
      </a>
    </div>
  );
};

export default EventComponent;
