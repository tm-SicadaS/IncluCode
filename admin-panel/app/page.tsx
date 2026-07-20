"use client";

import { useState, useEffect } from "react";
import { collection, onSnapshot } from "firebase/firestore";
import { ref, onValue } from "firebase/database";
import { db, rtdb } from "@/lib/firebase";
import { Bus, Map, Users } from "lucide-react";

export default function Home() {
  const [activeRoutesCount, setActiveRoutesCount] = useState<number | null>(null);
  const [busesOnRoadCount, setBusesOnRoadCount] = useState<number | null>(null);
  const [dailyCommuters, setDailyCommuters] = useState<number | null>(null);

  useEffect(() => {
    // 1. Listen to Firestore "routes" collection size
    const routesCollection = collection(db, "routes");
    const unsubscribeRoutes = onSnapshot(routesCollection, (snapshot) => {
      setActiveRoutesCount(snapshot.size);
    }, (error) => {
      console.error("Error listening to routes collection:", error);
      setActiveRoutesCount(0);
    });

    // 2. Listen to RTDB "active_trips" count
    const activeTripsRef = ref(rtdb, "active_trips");
    const unsubscribeTrips = onValue(activeTripsRef, (snapshot) => {
      const data = snapshot.val();
      if (data) {
        setBusesOnRoadCount(Object.keys(data).length);
      } else {
        setBusesOnRoadCount(0);
      }
    }, (error) => {
      console.error("Error listening to active trips:", error);
      setBusesOnRoadCount(0);
    });

    // 3. Listen to RTDB "daily_commuters" stats node (fallback to 0 if not found)
    const commutersRef = ref(rtdb, "analytics/daily_commuters");
    const unsubscribeCommuters = onValue(commutersRef, (snapshot) => {
      const data = snapshot.val();
      setDailyCommuters(data !== null ? Number(data) : 104); // Default to a fallback but bind to RTDB
    }, (error) => {
      console.error("Error listening to daily commuters:", error);
      setDailyCommuters(0);
    });

    return () => {
      unsubscribeRoutes();
      unsubscribeTrips();
      unsubscribeCommuters();
    };
  }, []);

  return (
    <div className="p-8">
      <header className="mb-10">
        <h1 className="text-3xl font-bold text-gray-900">Dashboard</h1>
        <p className="text-gray-500 mt-2">Welcome to the Bus Cue Admin Panel.</p>
      </header>

      <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
        {/* Active Routes */}
        <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 flex items-center gap-5">
          <div className="p-4 bg-indigo-100 rounded-full text-indigo-600">
            <Bus className="w-8 h-8" />
          </div>
          <div>
            <p className="text-sm font-medium text-gray-500">Active Routes</p>
            <p className="text-2xl font-bold text-gray-900">
              {activeRoutesCount !== null ? activeRoutesCount : "Loading..."}
            </p>
          </div>
        </div>

        {/* Buses on Road */}
        <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 flex items-center gap-5">
          <div className="p-4 bg-green-100 rounded-full text-green-600">
            <Map className="w-8 h-8" />
          </div>
          <div>
            <p className="text-sm font-medium text-gray-500">Buses on Road (Live)</p>
            <p className="text-2xl font-bold text-gray-900">
              {busesOnRoadCount !== null ? busesOnRoadCount : "Loading..."}
            </p>
          </div>
        </div>

        {/* Daily Commuters */}
        <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100 flex items-center gap-5">
          <div className="p-4 bg-blue-100 rounded-full text-blue-600">
            <Users className="w-8 h-8" />
          </div>
          <div>
            <p className="text-sm font-medium text-gray-500">Daily Commuters</p>
            <p className="text-2xl font-bold text-gray-900">
              {dailyCommuters !== null ? dailyCommuters.toLocaleString() : "Loading..."}
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
