using System.Collections.Generic;

public class GridObject
{
   private GridSystem gridSystem;
   private GridPosition gridPosition;
   private List<Unit> units;

   public GridObject(GridSystem gridSystem, GridPosition gridPosition)
   {
      this.gridSystem = gridSystem;
      this.gridPosition = gridPosition;
      units = new List<Unit>();
   }

   public override string ToString()
   {
      string unitText = "";

      foreach (Unit unit in units)
      {
         unitText += "\n" + unit.name;
      }

      return gridPosition.ToString() + unitText;
   }

   public void AddUnit(Unit unit)
   {
      units.Add(unit);
   }

   public void RemoveUnit(Unit unit)
   {
      units.Remove(unit);
   }

   public List<Unit> GetUnits()
   {
      return units;
   }
}
