import type { Metadata } from "next";
import { Inter } from "next/font/google";
import "./globals.css";
import Link from "next/link";
import { Map, Route, Bus } from "lucide-react";

const inter = Inter({ subsets: ["latin"] });

export const metadata: Metadata = {
  title: "Bus Cue Admin",
  description: "Transit accessibility system built for visually impaired commuters.",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en">
      <body className={`${inter.className} bg-slate-50 text-slate-900 min-h-screen flex`}>
        {/* Sidebar */}
        <aside className="w-64 bg-white text-slate-800 flex flex-col border-r border-slate-200">
          <div className="p-6 border-b border-slate-100 flex items-center gap-3">
            <Bus className="w-8 h-8 text-indigo-600" />
            <h1 className="text-2xl font-bold tracking-tight text-slate-900">Bus Cue</h1>
          </div>
          <nav className="flex-1 p-4 space-y-1">
            <Link 
              href="/" 
              className="flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-50 hover:text-indigo-600 transition-colors"
            >
              <Bus className="w-5 h-5" />
              <span className="font-medium">Dashboard</span>
            </Link>
            <Link 
              href="/routes" 
              className="flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-50 hover:text-indigo-600 transition-colors"
            >
              <Route className="w-5 h-5" />
              <span className="font-medium">Route Management</span>
            </Link>
            <Link 
              href="/fleet" 
              className="flex items-center gap-3 px-4 py-3 rounded-lg text-slate-600 hover:bg-slate-50 hover:text-indigo-600 transition-colors"
            >
              <Map className="w-5 h-5" />
              <span className="font-medium">Live Fleet</span>
            </Link>
          </nav>
          <div className="p-4 text-xs text-slate-400 text-center border-t border-slate-100">
            Admin Panel v1.0
          </div>
        </aside>

        {/* Main Content */}
        <main className="flex-1 overflow-y-auto">
          {children}
        </main>
      </body>
    </html>
  );
}
