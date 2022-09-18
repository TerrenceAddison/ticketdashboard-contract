import { NextComponentType } from "next";
import { uploadToPinata } from "../utils/uploadToPinata";
import { useContract, useContractWrite } from "@thirdweb-dev/react";
import { BigNumberish, BigNumber } from "ethers";

const EventCreation: NextComponentType = () => {
  const { contract } = useContract(
    "0x402783B28f2FFf17BDa063D14BC29B266ff707F3"
  );
  const {
    mutate: createEvent,
    isLoading,
    error,
  } = useContractWrite(contract, "createEvent");

  const handleSubmit = async (event: any) => {
    // Stop the form from submitting and refreshing the page.
    event.preventDefault();

    var purchaseStartDate = new Date(event.target.purchase_start_date.value);
    var purchaseStartDateEpoch = purchaseStartDate.getTime() / 1000;

    var purchaseEndDate = new Date(event.target.purchase_end_date.value);
    var purchaseEndDateEpoch = purchaseEndDate.getTime() / 1000;

    if (purchaseEndDateEpoch < purchaseStartDateEpoch) {
      alert("Purchase End Date need to be after Purchase Start Date");
      return;
    }

    var EventDate = new Date(event.target.event_date.value);
    var EventDateEpoch = EventDate.getTime() / 1000;

    if (EventDateEpoch < purchaseEndDateEpoch) {
      alert("Event Date need to be after Purchase End Date");
      return;
    }

    // Get data from the form.
    const data = {
      _eventName: event.target.event_name.value,
      _purchaseStartDate: purchaseStartDateEpoch,
      _purchaseEndDate: purchaseEndDateEpoch,
      _eventDate: EventDateEpoch,
      _ticketPrice: event.target.ticket_price.value,
      _tokenUri: "",
    };

    console.log(data);

    const result = await uploadToPinata(
      event.target.ticket_image.files,
      data._eventName,
      event.target.event_description.value
    );
    if (result) {
      data._tokenUri = `https://ipfs.io/ipfs/${result.data.IpfsHash}`;
      const tx = await contract.call(
        "createEvent",
        data._eventName,
        BigNumber.from(data._eventDate),
        BigNumber.from(data._purchaseStartDate),
        BigNumber.from(data._ticketPrice),
        BigNumber.from(data._purchaseEndDate),
        data._tokenUri
      );
      const receipt = tx.receipt;
      // const transaction = createEvent([
      //   data._eventName,
      //   BigNumber.from(data._eventDate),
      //   BigNumber.from(data._purchaseStartDate),
      //   BigNumber.from(data._ticketPrice),
      //   BigNumber.from(data._purchaseEndDate),
      //   data._tokenUri,
      // ]);
      console.log(receipt);
    } else {
      alert("Upload to IPFS Failed!");
    }
  };

  return (
    <form className="mx-8 min-h-screen" onSubmit={handleSubmit}>
      <h1 className="font-bold">Create a new event</h1>
      <h2 className="my-4">Event name:</h2>
      <input
        className=" border border-black rounded-md my-2 mx-8 p-2 text-black"
        type="text"
        id="event_name"
        name="event name"
        required
      />
      <h2 className="my-4">Event description:</h2>
      <input
        className=" border border-black rounded-md my-2 mx-8 p-2 text-black"
        type="text"
        id="event_description"
        name="event description"
        required
      />
      <h2>Event Date:</h2>
      <input
        className=" border border-black rounded-md my-2 mx-8 p-2 text-black"
        type="datetime-local"
        id="event_date"
        name="event Date"
        required
      />
      <h2>Purchase Start Date:</h2>
      <input
        className=" border border-black rounded-md my-2 mx-8 p-2 text-black"
        type="datetime-local"
        id="purchase_start_date"
        name="Purchase Start Date"
        required
      />
      <h2>Purchase End Date:</h2>
      <input
        className=" border border-black rounded-md my-2 mx-8 p-2 text-black"
        type="datetime-local"
        id="purchase_end_date"
        name="Purchase End Date"
        required
      />
      <h2>Ticket Price:</h2>
      <input
        className=" border border-black rounded-md my-2 mx-8 p-2 text-black"
        type="number"
        id="ticket_price"
        name="Ticket Price"
        required
      />
      <h2>Ticket Image:</h2>
      <input
        className=" border border-black rounded-md my-2 mx-8 p-2 text-black"
        type="file"
        id="ticket_image"
        name="Ticket_Image"
        required
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

export default EventCreation;
