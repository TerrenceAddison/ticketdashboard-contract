import type { AppProps } from "next/app";
import { ChainId, ThirdwebProvider } from "@thirdweb-dev/react";
import Header from "../components/Header/Header";
import "../styles/globals.css";
import Footer from "../components/Footer/Footer";

// This is the chainId your dApp will work on.
const activeChainId = ChainId.Mumbai;

function MyApp({ Component, pageProps }: AppProps) {
  return (
    <div className="bg-black min-h-screen">
      <ThirdwebProvider desiredChainId={activeChainId}>
        <Header />
        <Component {...pageProps} />
        <Footer />
      </ThirdwebProvider>
    </div>
  );
}

export default MyApp;
