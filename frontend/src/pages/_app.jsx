import '/src/styles/globals.css'
import Navbar from '@components/Navbar'

export default function App({ Component, pageProps }) {
  return <div className='w-full min-h-screen flex flex-col'>
    <Navbar></Navbar>
    <main className='w-full flex-1 flex'>
    <Component {...pageProps} />
    </main>
  </div>
}
