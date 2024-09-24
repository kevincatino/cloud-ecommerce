import '/src/styles/globals.css'
import '/src/styles/custom.css'
import Navbar from '@components/Navbar'

export default function App({ Component, pageProps }) {
  return <div className='w-full bg-primary min-h-screen flex flex-col'>
    <Navbar/>
    <main className='w-full flex-1 flex'>
    <Component {...pageProps} />
    </main>
  </div>
}
