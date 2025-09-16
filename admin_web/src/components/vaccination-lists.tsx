import React from "react";
import { Card, CardContent, CardHeader, CardTitle } from "./ui/card";
import { CheckCircle, Clock, AlertTriangle } from "lucide-react";
import { ScrollArea } from "./ui/scroll-area";

interface VaccineItem {
  name: string;
  date?: string;
  status: "applied" | "pending" | "overdue";
}

export const mockVaccines: VaccineItem[] = [
  // Vacinas Aplicadas
  { name: "COVID-19 (1ª dose)", date: "15/03/2024", status: "applied" },
  { name: "Influenza 2024", date: "10/04/2024", status: "applied" },
  { name: "Hepatite B (1ª dose)", date: "22/02/2024", status: "applied" },
  { name: "Tétano (1ª dose)", date: "05/01/2024", status: "applied" },
  { name: "Pneumocócica 13", date: "18/12/2023", status: "applied" },
  { name: "Meningocócica ACWY", date: "25/11/2023", status: "applied" },
  { name: "HPV (1ª dose)", date: "08/10/2023", status: "applied" },
  { name: "Varicela (Catapora)", date: "12/09/2023", status: "applied" },

  // Vacinas Pendentes
  { name: "COVID-19 (2ª dose)", status: "pending" },
  { name: "Hepatite B (2ª dose)", status: "pending" },
  { name: "Tétano (reforço)", status: "pending" },
  { name: "HPV (2ª dose)", status: "pending" },
  { name: "Pneumocócica 23", status: "pending" },
  { name: "Influenza 2025", status: "pending" },
  { name: "Hepatite A", status: "pending" },
  { name: "Tríplice Viral (Reforço)", status: "pending" },

  // Vacinas Atrasadas
  { name: "Febre Amarela", status: "overdue" },
  { name: "COVID-19 (3ª dose)", status: "overdue" },
  { name: "dTpa (Tríplice Bacteriana)", status: "overdue" },
  { name: "Hepatite B (3ª dose)", status: "overdue" },
];

export const VaccinationLists: React.FC = () => {
  const appliedVaccines = mockVaccines.filter((v) => v.status === "applied");
  const pendingVaccines = mockVaccines.filter((v) => v.status === "pending");
  const overdueVaccines = mockVaccines.filter((v) => v.status === "overdue");

  const VaccineListItem: React.FC<{ vaccine: VaccineItem }> = ({ vaccine }) => {
    const getIcon = () => {
      switch (vaccine.status) {
        case "applied":
          return <CheckCircle className="h-4 w-4 text-green-500" />;
        case "pending":
          return <Clock className="h-4 w-4 text-yellow-500" />;
        case "overdue":
          return <AlertTriangle className="h-4 w-4 text-red-500" />;
      }
    };

    const getBorderColor = () => {
      switch (vaccine.status) {
        case "applied":
          return "border-l-green-500";
        case "pending":
          return "border-l-yellow-500";
        case "overdue":
          return "border-l-red-500";
      }
    };

    return (
      <div
        className={`p-3 border-l-4 ${getBorderColor()} bg-white rounded-r-md mb-2`}
      >
        <div className="flex items-center gap-2">
          {getIcon()}
          <div className="flex-1">
            <p className="text-sm font-medium">{vaccine.name}</p>
            {vaccine.date && (
              <p className="text-xs text-muted-foreground">
                Aplicada em: {vaccine.date}
              </p>
            )}
          </div>
        </div>
      </div>
    );
  };

  return (
    <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
      {/* Vacinas Aplicadas */}
      <Card>
        <CardHeader className="pb-3">
          <CardTitle className="text-lg flex items-center gap-2">
            <CheckCircle className="h-5 w-5 text-green-500" />
            Aplicadas
          </CardTitle>
        </CardHeader>
        <CardContent>
          <ScrollArea className="h-64">
            {appliedVaccines.length > 0 ? (
              appliedVaccines.map((vaccine, index) => (
                <VaccineListItem key={index} vaccine={vaccine} />
              ))
            ) : (
              <p className="text-sm text-muted-foreground text-center py-4">
                Nenhuma vacina aplicada
              </p>
            )}
          </ScrollArea>
        </CardContent>
      </Card>

      {/* Vacinas Pendentes */}
      <Card>
        <CardHeader className="pb-3">
          <CardTitle className="text-lg flex items-center gap-2">
            <Clock className="h-5 w-5 text-yellow-500" />
            Pendentes
          </CardTitle>
        </CardHeader>
        <CardContent>
          <ScrollArea className="h-64">
            {pendingVaccines.length > 0 ? (
              pendingVaccines.map((vaccine, index) => (
                <VaccineListItem key={index} vaccine={vaccine} />
              ))
            ) : (
              <p className="text-sm text-muted-foreground text-center py-4">
                Nenhuma vacina pendente
              </p>
            )}
          </ScrollArea>
        </CardContent>
      </Card>

      {/* Vacinas Atrasadas */}
      <Card>
        <CardHeader className="pb-3">
          <CardTitle className="text-lg flex items-center gap-2">
            <AlertTriangle className="h-5 w-5 text-red-500" />
            Atrasadas
          </CardTitle>
        </CardHeader>
        <CardContent>
          <ScrollArea className="h-64">
            {overdueVaccines.length > 0 ? (
              overdueVaccines.map((vaccine, index) => (
                <VaccineListItem key={index} vaccine={vaccine} />
              ))
            ) : (
              <p className="text-sm text-muted-foreground text-center py-4">
                Nenhuma vacina atrasada
              </p>
            )}
          </ScrollArea>
        </CardContent>
      </Card>
    </div>
  );
};
