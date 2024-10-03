using System;
using System.Data;
using System.Data.SqlClient;

namespace AsignarSaldosAGestores
{
    class Program
    {
        static void Main(string[] args)
        {
            string connectionString = "Server=DESKTOP-8O4EURI;Database=Netforemost;Trusted_Connection=True;";

            using(SqlConnection con = new SqlConnection(connectionString))
            {
                try
                {
                    //Abrimos la conexion a la base de datos
                    con.Open ();

                    //Definimos el comando para ejecutar el procedimiento almacenado
                    SqlCommand cmd = new SqlCommand ("AsignarSaldosAGestores", con);
                    cmd.CommandType = CommandType.StoredProcedure;

                    //Ejecutamos el comando y obtenemos los resultados
                    SqlDataReader reader = cmd.ExecuteReader ();

                    //Iteramos sobre los resultados
                    Console.WriteLine("Saldo asignado a cada gestor: ");
                    while (reader.Read ())
                    {
                        Console.WriteLine($"Saldo: {reader["Saldo"]}, Gestor: {reader["Gestor"]}");
                    }

                    //Cerramos el lector
                    reader.Close ();
                }
                catch (Exception ex) 
                {
                    Console.WriteLine($"Error:{ex.Message}");
                }
              
            }

            Console.WriteLine("Presione cualquier tecla para salir...");
            Console.ReadKey();
        }
    }
}