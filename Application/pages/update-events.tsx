import { NextComponentType } from "next";

const EventUpdate: NextComponentType = () => {
  return (
    <form className="mx-8 h-screen" action="/send-data-here" method="post">
      <h1 className="font-bold">Update an event</h1>
      <h2 className="my-4">Event name:</h2>
      <input
        className=" border border-black rounded-md my-2 mx-8 p-2 text-black"
        type="text"
        id="event name"
        name="event name"
      />
      <h2>Event description:</h2>
      <input
        className=" border border-black rounded-md my-2 mx-8 p-2 text-black"
        type="text"
        id="event description"
        name="event description"
      />
      <div className="mx-8">
        <button
          className="bg-white text-black py-3 px-4 rounded-md text-xl my-8"
          type="submit"
        >
          Submit
        </button>
      </div>
    </form>
  );
};

export default EventUpdate;
