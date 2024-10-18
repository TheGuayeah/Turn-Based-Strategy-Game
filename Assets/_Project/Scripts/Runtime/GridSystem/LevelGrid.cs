using System;
using System.Collections.Generic;
using UnityEngine;

public class LevelGrid : Singleton<LevelGrid>
{
   public event EventHandler OnAnyUnitMovedGridPosition;

   public const float FLOOR_HEIGHT = 3f;

   [SerializeField]
   private Transform gridDebugPrefab;
   [SerializeField]
   private int width;
   [SerializeField]
   private int height;
   [SerializeField]
   private float cellSize;
   [SerializeField]
   private int floorAmount;

   private List<GridSystem<GridObject>> gridSystemList;

   protected override void Awake()
   {
      base.Awake();

      gridSystemList = new List<GridSystem<GridObject>>();

      for (int floor = 0; floor < floorAmount; floor++)
      {
         GridSystem<GridObject>  gridSystem = new GridSystem<GridObject>(
            width, height, cellSize, floor, FLOOR_HEIGHT,
            (GridSystem<GridObject> g, 
            GridPosition gridPosition) => new GridObject(g, gridPosition)
         );

         gridSystemList.Add(gridSystem);
      }
      
      //gridSystem.CreateDebugObjects(gridDebugPrefab, transform);
   }

   private void Start()
   {
      Pathfinding.Instance.SetUp(width, height, cellSize);
   }

   public GridSystem<GridObject> GetGridSystemAtFloor(int floor)
   {
      return gridSystemList[floor];
   }

   public void AddUnitAtGridPosition(GridPosition gridPosition, Unit unit)
   {
      GridObject gridObject = 
         GetGridSystemAtFloor(gridPosition.floor).GetGridObject(gridPosition);

      gridObject.AddUnit(unit);
   }

   public List<Unit> GetUnitsFromGridPosition(GridPosition gridPosition)
   {
      GridObject gridObject = 
         GetGridSystemAtFloor(gridPosition.floor).GetGridObject(gridPosition);

      return gridObject.GetUnits();
   }

   public void RemoveUnitAtGridPosition(GridPosition gridPosition, Unit unit)
   {
      GridObject gridObject =
         GetGridSystemAtFloor(gridPosition.floor).GetGridObject(gridPosition);
      gridObject.RemoveUnit(unit);
   }

   public void UnitMovedGridPosition(Unit unit, GridPosition origin, GridPosition destination)
   {
      RemoveUnitAtGridPosition(origin, unit);
      AddUnitAtGridPosition(destination, unit);
      OnAnyUnitMovedGridPosition?.Invoke(this, EventArgs.Empty);
   }

   public int GetFloor(Vector3 worldPosition)
   {
      return Mathf.RoundToInt(worldPosition.y / FLOOR_HEIGHT);
   }

   public GridPosition GetGridPosition(Vector3 worldPosition)
   {
      int floor = GetFloor(worldPosition);

      // If the floor is out of bounds, return a grid position with the highest floor
      if (floor < 0 || floor >= floorAmount)
         return GetGridSystemAtFloor(floorAmount - 1).GetGridPosition(worldPosition);

      return GetGridSystemAtFloor(floor).GetGridPosition(worldPosition);
   }

   public Vector3 GetWorldPosition(GridPosition gridPosition)
   {
      return GetGridSystemAtFloor(gridPosition.floor).GetWorldPosition(gridPosition);
   }

   public bool IsValidGridPosition(GridPosition gridPosition)
   {
      return GetGridSystemAtFloor(gridPosition.floor).IsValidGridPosition(gridPosition);
   }

   public int GetWidth()
   {
      return GetGridSystemAtFloor(0).GetWidth();
   }

   public int GetHeight()
   {
      return GetGridSystemAtFloor(0).GetHeight();
   }

   public bool IsAnyUnitAtGridPosition(GridPosition gridPosition)
   {
      GridObject gridObject = 
         GetGridSystemAtFloor(gridPosition.floor).GetGridObject(gridPosition);

      return gridObject.HasAnyUnit();
   }

   public Unit GetUnitFromGridPosition(GridPosition gridPosition)
   {
      GridObject gridObject = 
         GetGridSystemAtFloor(gridPosition.floor).GetGridObject(gridPosition);

      return gridObject.GetUnit();
   }

   public IInteractable GetInteractableFromGridPsoition(GridPosition gridPosition)
   {
      GridObject gridObject = 
         GetGridSystemAtFloor(gridPosition.floor).GetGridObject(gridPosition);

      return gridObject.GetInteractable();
   }

   public void SetInteractableAtGridPosition(GridPosition gridPosition, IInteractable interactable)
   {
      GridObject gridObject = 
         GetGridSystemAtFloor(gridPosition.floor).GetGridObject(gridPosition);

      gridObject.SetInteractable(interactable);
   }
}
