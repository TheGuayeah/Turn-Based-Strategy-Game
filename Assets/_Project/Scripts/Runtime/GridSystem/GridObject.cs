using System.Collections.Generic;

public class GridObject
{
   private GridSystem<GridObject> gridSystem;
   private GridPosition gridPosition;
   private List<Unit> units;
   private IInteractable interactable;

   public GridObject(GridSystem<GridObject> gridSystem, GridPosition gridPosition)
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

   public bool HasAnyUnit()
   {
      return units.Count > 0;
   }

   public Unit GetUnit()
   {
      return HasAnyUnit() ? units[0] : null;
   }

   public IInteractable GetInteractable()
   {
      return interactable;
   }

   public void SetInteractable(IInteractable interactable)
   {
      this.interactable = interactable;
   }
}
