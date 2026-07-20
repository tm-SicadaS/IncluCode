"use client";

import { useState, useEffect } from "react";
import { ref, onValue } from "firebase/database";
import { rtdb } from "@/lib/firebase";
import { Map as MapIcon, Navigation, SignalHigh } from "lucide-react";

export default function FleetPage() {
  const [activeTrips, setActiveTrips] = useState<any>(null);
  const [lastUpdated, setLastUpdated] = useState<Date | null>(null);

  useEffect(() => {
    const tripsRef = ref(rtdb, "active_trips");
    
    const unsubscribe = onValue(tripsRef, (snapshot) => {
      const data = snapshot.val();
      setActiveTrips(data || {});
      setLastUpdated(new Date());
    }, (error) => {
      console.error("Error fetching RTDB:", error);
    });

    return () => unsubscribe();
  }, []);

  return (
    <div className="p-8">
      <header className="mb-10 flex justify-between items-end">
        <div>
          <h1 className="text-3xl font-bold text-gray-900">Live Fleet Tracking</h1>
          <p className="text-gray-500 mt-2">Real-time GPS updates from active buses on the road.</p>
        </div>
        <div className="flex items-center gap-2 text-sm">
          <SignalHigh className="w-4 h-4 text-green-500 animate-pulse" />
          <span className="text-gray-500 font-medium">
            Live {lastUpdated ? `(Updated: ${lastUpdated.toLocaleTimeString()})` : "(Connecting...)"}
          </span>
        </div>
      </header>

      <div className="grid grid-cols-1 lg:grid-cols-4 gap-8">
        <div className="lg:col-span-3">
          <div className="bg-slate-100 rounded-2xl shadow-sm border border-slate-200 overflow-hidden h-[600px] flex flex-col relative">
            {/* Placeholder for Map */}
            <div className="absolute inset-0 bg-slate-200/35 flex flex-col items-center justify-center text-slate-500 z-0">
              <MapIcon className="w-16 h-16 mb-4 opacity-40 text-slate-400" />
              <p className="text-lg font-semibold text-slate-700">Google Maps Integration Pending</p>
              <p className="text-sm text-slate-500">Visual layer will be added here</p>
            </div>

            {/* Raw Data Overlay */}
            <div className="relative z-10 flex-1 p-6 flex flex-col justify-end items-start">
              <div className="bg-white/95 backdrop-blur-md border border-slate-200/80 rounded-xl p-4 max-h-[250px] overflow-auto font-mono text-sm text-slate-700 shadow-md w-full max-w-md">
                <div className="mb-2 text-slate-600 font-semibold flex items-center gap-2">
                  <Navigation className="w-4 h-4 text-indigo-500" /> /active_trips dump:
                </div>
                <pre className="text-slate-600 text-xs">
                  {JSON.stringify(activeTrips, null, 2)}
                </pre>
              </div>
            </div>
          </div>
        </div>

        <div className="lg:col-span-1">
          <div className="bg-white rounded-2xl shadow-sm border border-gray-100 p-6 h-full">
            <h2 className="font-semibold text-gray-900 mb-4 border-b border-gray-100 pb-2">
              Active Vehicles ({activeTrips ? Object.keys(activeTrips).length : 0})
            </h2>
            
            <div className="space-y-4">
              {activeTrips && Object.keys(activeTrips).length > 0 ? (
                Object.entries(activeTrips).map(([tripId, data]: [string, any]) => (
                  <div key={tripId} className="bg-gray-50 border border-gray-100 p-3 rounded-lg text-sm">
                    <p className="font-semibold text-gray-800 mb-1">{data.routeName || `Trip: ${tripId}`}</p>
                    <div className="flex justify-between text-gray-500 font-mono text-xs mt-2">
                      <span>Lat: {data.latitude?.toFixed(4) || "N/A"}</span>
                      <span>Lng: {data.longitude?.toFixed(4) || "N/A"}</span>
                    </div>
                  </div>
                ))
              ) : (
                <p className="text-sm text-gray-500 text-center py-4">No active trips detected.</p>
              )}
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
