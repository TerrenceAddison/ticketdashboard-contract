import type { NextPage } from "next";
import { useAddress, useContract, useContractRead } from "@thirdweb-dev/react";
import EventComponent from "../components/Events/EventComponent";
import React from "react";

const Events: NextPage = () => {
  const address = useAddress();
  const { contract } = useContract(
    "0x402783B28f2FFf17BDa063D14BC29B266ff707F3"
  );
  const { data: s_eventId, isLoading } = useContractRead(contract, "s_eventId");

  const [reached, isReached] = React.useState(false);
  const [events, setEvents] = React.useState([]);

  React.useEffect(() => {
    async function fetchData() {
      let allEvents = [];
      console.log(s_eventId);
      for (let i = 0; i < s_eventId.toNumber(); i++) {
        console.log(s_eventId);
        const returnedData = await contract?.call("getEventInfo", s_eventId);
        let event = {
          id: i,
          eventName: returnedData[0],
          eventOwner: returnedData[1],
          eventDate: returnedData[2],
          purchaseStartDate: returnedData[3],
          purchaseEndDate: returnedData[4],
          ticketPrice: returnedData[5],
          eventContract: returnedData[6],
        };
        allEvents.push(event);
      }
      console.log(allEvents);
      setEvents(allEvents);
      isReached(true);
    }
    if (s_eventId && !reached) {
      fetchData();
    }
  });

  return (
    <div className="px-9">
      <div className="h-screen flex justify-center content-center py-20 flex-wrap">
        {reached && events.length > 0
          ? events.map((event) => {
              return (
                <EventComponent
                  title={event.eventName}
                  id={event.id}
                  address={event.eventContract}
                />
              );
            })
          : null}
      </div>
    </div>
  );
};

export default Events;
