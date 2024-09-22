import Link from 'next/link'
import SearchBar from './SearchBar'

export default function Navbar() {
    return <header className='bg-secondary font-serif w-full h-12 flex items-center'>
      <Link href={'/'} className='px-2 font-bold'>
      E-commerce System
      </Link>
      
    </header>
  }