"use client";

import { useState, useEffect } from "react";
import { collection, addDoc, onSnapshot, query, orderBy, serverTimestamp } from "firebase/firestore";
import { db } from "@/lib/firebase";
import { v4 as uuidv4 } from "uuid";
import { Plus, Route as RouteIcon, Search } from "lucide-react";

interface RouteData {
  id: string;
  routeName: string;
  bleUuid: string;
  createdAt: any;
}

export default function RoutesPage() {
  const [routes, setRoutes] = useState<RouteData[]>([]);
  const [routeName, setRouteName] = useState("");
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const q = query(collection(db, "routes"), orderBy("createdAt", "desc"));
    const unsubscribe = onSnapshot(q, (snapshot) => {
      const routesData = snapshot.docs.map(doc => ({
        id: doc.id,
        ...doc.data()
      })) as RouteData[];
      setRoutes(routesData);
    });

    return () => unsubscribe();
  }, []);

  const handleAddRoute = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!routeName.trim()) return;

    setLoading(true);
    try {
      const newUuid = uuidv4();
      await addDoc(collection(db, "routes"), {
        routeName: routeName.trim(),
        bleUuid: newUuid,
        distanceKm: 0,
        stops: [],
        audioCueId: "",
        createdAt: serverTimestamp()
      });
      setRouteName("");
    } catch (error) {
      console.error("Error adding route:", error);
      alert("Failed to add route.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="p-8">
      <header className="mb-10">
        <h1 className="text-3xl font-bold text-gray-900">Route Management</h1>
        <p className="text-gray-500 mt-2">Manage bus routes and BLE UUIDs for visual accessibility cues.</p>
      </header>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-8">
        {/* Add Route Form */}
        <div className="lg:col-span-1">
          <div className="bg-white p-6 rounded-2xl shadow-sm border border-gray-100">
            <h2 className="text-xl font-semibold mb-4 flex items-center gap-2">
              <Plus className="w-5 h-5 text-indigo-600" /> Add New Route
            </h2>
            <form onSubmit={handleAddRoute} className="space-y-4">
              <div>
                <label htmlFor="routeName" className="block text-sm font-medium text-gray-700 mb-1">
                  Route Name
                </label>
                <input
                  type="text"
                  id="routeName"
                  value={routeName}
                  onChange={(e) => setRouteName(e.target.value)}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-indigo-500 focus:border-indigo-500 outline-none transition-all"
                  placeholder="e.g. 104 Express"
                  required
                />
              </div>
              <button
                type="submit"
                disabled={loading}
                className="w-full bg-indigo-600 hover:bg-indigo-700 text-white font-medium py-2 px-4 rounded-lg transition-colors disabled:opacity-50"
              >
                {loading ? "Adding..." : "Generate & Save Route"}
              </button>
            </form>
          </div>
        </div>

        {/* Routes Table */}
        <div className="lg:col-span-2">
          <div className="bg-white rounded-2xl shadow-sm border border-gray-100 overflow-hidden">
            <div className="p-6 border-b border-gray-100 flex justify-between items-center bg-gray-50/50">
              <h2 className="text-xl font-semibold flex items-center gap-2">
                <RouteIcon className="w-5 h-5 text-indigo-600" /> Active Routes
              </h2>
              <div className="relative">
                <Search className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2 text-gray-400" />
                <input 
                  type="text" 
                  placeholder="Search routes..." 
                  className="pl-9 pr-4 py-2 text-sm border border-gray-200 rounded-lg focus:outline-none focus:ring-2 focus:ring-indigo-500"
                />
              </div>
            </div>
            
            <div className="overflow-x-auto">
              <table className="w-full text-left border-collapse">
                <thead>
                  <tr className="bg-gray-50 border-b border-gray-100">
                    <th className="py-3 px-6 text-sm font-semibold text-gray-600">Route Name</th>
                    <th className="py-3 px-6 text-sm font-semibold text-gray-600">BLE UUID</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-gray-100">
                  {routes.length === 0 ? (
                    <tr>
                      <td colSpan={2} className="py-8 text-center text-gray-500">
                        No routes found. Create one to get started.
                      </td>
                    </tr>
                  ) : (
                    routes.map((route) => (
                      <tr key={route.id} className="hover:bg-gray-50/50 transition-colors">
                        <td className="py-4 px-6 font-medium text-gray-900">{route.routeName}</td>
                        <td className="py-4 px-6 font-mono text-sm text-indigo-600 bg-indigo-50/30">
                          {route.bleUuid}
                        </td>
                      </tr>
                    ))
                  )}
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
