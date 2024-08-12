using System.Collections.Generic;
using UnityEngine;

public class LevelGrid : Singleton<LevelGrid>
{
   [SerializeField]
   private Transform gridDebugPrefab;

   private GridSystem gridSystem;

   protected override void Awake()
   {
      base.Awake();
      gridSystem = new GridSystem(10, 10, 2f);
      gridSystem.CreateDebugObjects(gridDebugPrefab, transform);
   }

   public void AddUnitAtGridPosition(GridPosition gridPosition, Unit unit)
   {
      GridObject gridObject = gridSystem.GetGridObject(gridPosition);
      gridObject.AddUnit(unit);
   }

   public List<Unit> GetUnitsFromGridPosition(GridPosition gridPosition)
   {
      GridObject gridObject = gridSystem.GetGridObject(gridPosition);
      return gridObject.GetUnits();
   }

   public void RemoveUnitAtGridPosition(GridPosition gridPosition, Unit unit)
   {
      GridObject gridObject = gridSystem.GetGridObject(gridPosition);
      gridObject.RemoveUnit(unit);
   }

   public void UnitMovedGridPosition(Unit unit, GridPosition origin, GridPosition destination)
   {
      RemoveUnitAtGridPosition(origin, unit);
      AddUnitAtGridPosition(destination, unit);
   }

   public GridPosition GetGridPosition(Vector3 worldPosition)
   {
      return gridSystem.GetGridPosition(worldPosition);
   }

   public Vector3 GetWorldPosition(GridPosition gridPosition)
   {
      return gridSystem.GetWorldPosition(gridPosition);
   }

   public bool IsValidGridPosition(GridPosition gridPosition)
   {
      return gridSystem.IsValidGridPosition(gridPosition);
   }

   public int GetWidth()
   {
      return gridSystem.GetWidth();
   }

   public int GetHeight()
   {
      return gridSystem.GetHeight();
   }

   public bool IsAnyUnitAtGridPosition(GridPosition gridPosition)
   {
      GridObject gridObject = gridSystem.GetGridObject(gridPosition);
      return gridObject.HasAnyUnit();
   }

   public Unit GetUnitFromGridPosition(GridPosition gridPosition)
   {
      GridObject gridObject = gridSystem.GetGridObject(gridPosition);
      return gridObject.GetUnit();
   }
}
