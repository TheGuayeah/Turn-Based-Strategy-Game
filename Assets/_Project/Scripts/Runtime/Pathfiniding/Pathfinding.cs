using System.Collections.Generic;
using UnityEngine;

public class Pathfinding : Singleton<Pathfinding>
{
   private const int MOVE_STRAIGHT_COST = 10;
   private const int MOVE_DIAGONAL_COST = 14;

   [SerializeField]
   private Transform gridDebugPrefab;
   [SerializeField] 
   private LayerMask obstaclesLayerMask;
   [SerializeField]
   private LayerMask floorLayerMask;

   private int width;
   private int height;
   private float cellSize;
   private int floorAmount;
   List<GridSystem<PathNode>> gridSystemList;

   protected override void Awake()
   {
      base.Awake();
   }

   public void SetUp(int width, int height, float cellSize, int floorAmount)
   {
      this.width = width;
      this.height = height;
      this.cellSize = cellSize;
      this.floorAmount = floorAmount;

      gridSystemList = new List<GridSystem<PathNode>>();

      for (int floor = 0; floor < floorAmount; floor++)
      {
         GridSystem<PathNode> gridSystem = 
            new GridSystem<PathNode>(width, height, cellSize, floor,
               LevelGrid.FLOOR_HEIGHT, (GridSystem<PathNode> g, 
               GridPosition gridPosition) => new PathNode(gridPosition)
            );

         gridSystemList.Add(gridSystem);
      }

      for (int x = 0; x < width; x++)
      {
         for (int z = 0; z < height; z++)
         {
            for (int floor = 0; floor < floorAmount; floor++)
            {
               GridPosition gridPosition = new GridPosition(x, z, floor);
               Vector3 worldPosition = LevelGrid.Instance.GetWorldPosition(gridPosition);
               float raycasOffsetDistance = 1f;

               GetNode(x, z, floor).SetIsWalkable(false);

               bool floorFound = Physics.Raycast(
                  worldPosition + Vector3.up * raycasOffsetDistance,
                  Vector3.down,
                  raycasOffsetDistance * 2,
                  floorLayerMask
               );

               if (floorFound)
               {
                  GetNode(x, z, floor).SetIsWalkable(true);
               }

               bool obstacleFound = Physics.Raycast(
                  worldPosition + Vector3.down * raycasOffsetDistance,
                  Vector3.up,
                  raycasOffsetDistance * 2,
                  obstaclesLayerMask
               );

               if (obstacleFound)
               {
                  GetNode(x, z, floor).SetIsWalkable(false);
               }
            }            
         }
      }
   }

   public List<GridPosition> FindPath(
      GridPosition startPosition, 
      GridPosition endPosition,
      out int pathLength
   )
   {
      List<PathNode> openList = new List<PathNode>(); //still searching
      List<PathNode> closedList = new List<PathNode>(); //already searched

      PathNode startNode = GetGridSystem(startPosition.floor).GetGridObject(startPosition);
      PathNode endNode = GetGridSystem(endPosition.floor).GetGridObject(endPosition);

      openList.Add(startNode);

      for (int x = 0; x < width; x++)
      {
         for (int z = 0; z < height; z++)
         {
            for (int floor = 0; floor < floorAmount; floor++)
            {
               GridPosition gridPosition = new GridPosition(x, z, floor);
               PathNode pathNode = GetGridSystem(floor).GetGridObject(gridPosition);

               pathNode.SetGCost(int.MaxValue);
               pathNode.SetHCost(0);
               pathNode.CalculateFCost();
               pathNode.ResetCameFromPathNode();
            }
         }
      }

      startNode.SetGCost(0);
      startNode.SetHCost(CalculateDistance(startPosition, endPosition));
      startNode.CalculateFCost();

      while (openList.Count > 0) 
      {
         PathNode currentNode = GetLowestFCostNode(openList);

         if(currentNode == endNode)
         {
            // Reached our destination
            pathLength = currentNode.GetFCost();
            return CalculatePath(endNode);
         }

         openList.Remove(currentNode);
         closedList.Add(currentNode);

         foreach (PathNode neighbourNode in GetNeighbours(currentNode))
         {
            if (closedList.Contains(neighbourNode)) continue;

            if (!neighbourNode.IsWalkable())
            {
               closedList.Add(neighbourNode);
               continue;
            }

            int tentativeGCost = currentNode.GetGCost() + CalculateDistance(
                  currentNode.GetGridPosition(), 
                  neighbourNode.GetGridPosition()
            );

            if(tentativeGCost < neighbourNode.GetGCost())
            {
               neighbourNode.SetCameFromPathNode(currentNode);
               neighbourNode.SetGCost(tentativeGCost);
               neighbourNode.SetHCost(CalculateDistance(
                  neighbourNode.GetGridPosition(), endPosition)
               );
               neighbourNode.CalculateFCost();

               if (!openList.Contains(neighbourNode))
               {
                  openList.Add(neighbourNode);
               }
            }
         }
      }

      // No path found
      pathLength = 0;
      return null;
   }

   private int CalculateDistance(GridPosition startPosition, GridPosition endPosition)
   {
      GridPosition gridDistance = startPosition - endPosition;
      int xDistance = Mathf.Abs(gridDistance.x);
      int zDistance = Mathf.Abs(gridDistance.z);
      int remaining = Mathf.Abs(xDistance - zDistance);

      return MOVE_DIAGONAL_COST * Mathf.Min(xDistance, zDistance) +
         MOVE_STRAIGHT_COST * remaining;
   }

   private PathNode GetLowestFCostNode(List<PathNode> pathNodes)
   {
      PathNode lowestFCostNode = pathNodes[0];
      for (int i = 1; i < pathNodes.Count; i++)
      {
         if (pathNodes[i].GetFCost() < lowestFCostNode.GetFCost())
         {
            lowestFCostNode = pathNodes[i];
         }
      }
      return lowestFCostNode;
   }

   private GridSystem<PathNode> GetGridSystem(int floor)
   {
      return gridSystemList[floor];
   }

   private PathNode GetNode(int x, int z, int floor)
   {
      return GetGridSystem(floor).GetGridObject(new GridPosition(x, z, floor));
   }

   private List<PathNode> GetNeighbours(PathNode currentNode)
   {
      List<PathNode> neighbours = new List<PathNode>();

      GridPosition gridPosition = currentNode.GetGridPosition();

      if(gridPosition.x - 1 >= 0)
      {
         //Left
         neighbours.Add(
            GetNode(gridPosition.x - 1, gridPosition.z, gridPosition.floor)
         );

         if(gridPosition.z - 1 >= 0)
         {
            //LeftDown
            neighbours.Add(
               GetNode(gridPosition.x - 1, gridPosition.z - 1, gridPosition.floor)
            );
         }
         if (gridPosition.z + 1 < height)
         {
            //LeftUp
            neighbours.Add(
               GetNode(gridPosition.x - 1, gridPosition.z + 1, gridPosition.floor)
            );
         }
      }
      
      if (gridPosition.x + 1 < width)
      {
         //Right
         neighbours.Add(
            GetNode(gridPosition.x + 1, gridPosition.z, gridPosition.floor)
         );

         if (gridPosition.z - 1 >= 0)
         {
            //RightDown
            neighbours.Add(
               GetNode(gridPosition.x + 1, gridPosition.z - 1, gridPosition.floor)
            );
         }
         if (gridPosition.z + 1 < height)
         {
            //RightUp
            neighbours.Add(
               GetNode(gridPosition.x + 1, gridPosition.z + 1, gridPosition.floor)
            );
         }
      }

      if (gridPosition.z - 1 >= 0)
      {
         //Down
         neighbours.Add(
            GetNode(gridPosition.x, gridPosition.z - 1, gridPosition.floor)
         );
      }
      if (gridPosition.z + 1 < height)
      {
         //Up
         neighbours.Add(
            GetNode(gridPosition.x, gridPosition.z + 1, gridPosition.floor)
         );
      }

      List<PathNode> totalNeighbours = new List<PathNode>();
      totalNeighbours.AddRange(neighbours);

      foreach (PathNode pathNode in neighbours)
      {
         GridPosition neighbourGridPosition = pathNode.GetGridPosition();

         if(neighbourGridPosition.floor - 1 >= 0)
         {
            totalNeighbours.Add(GetNode(
               neighbourGridPosition.x, 
               neighbourGridPosition.z, 
               neighbourGridPosition.floor - 1
            ));
         }

         if (neighbourGridPosition.floor + 1 < floorAmount)
         {
            totalNeighbours.Add(GetNode(
               neighbourGridPosition.x,
               neighbourGridPosition.z,
               neighbourGridPosition.floor + 1
            ));
         }
      }

      return totalNeighbours;
   }

   private List<GridPosition> CalculatePath(PathNode endNode)
   {
      List<PathNode> path = new List<PathNode>();

      path.Add(endNode);
      PathNode currentNode = endNode;

      while (currentNode.GetCameFromPathNode() != null)
      {
         path.Add(currentNode.GetCameFromPathNode());
         currentNode = currentNode.GetCameFromPathNode();
      }

      path.Reverse();

      List<GridPosition> pathGridPositions = new List<GridPosition>();

      foreach (PathNode pathNode in path)
      {
         pathGridPositions.Add(pathNode.GetGridPosition());
      }

      return pathGridPositions;
   }

   public void SetIsWalkableGridPosition(GridPosition gridPosition, bool isWalkable)
   {
      PathNode pathNode = GetGridSystem(gridPosition.floor).GetGridObject(gridPosition);
      pathNode.SetIsWalkable(isWalkable);
   }

   public bool IsWalkableGridPosition(GridPosition gridPosition)
   {
      PathNode pathNode = GetGridSystem(gridPosition.floor).GetGridObject(gridPosition);
      return pathNode.IsWalkable();
   }

   public bool HasPath(GridPosition startPosition, GridPosition endPosition)
   {
      return FindPath(startPosition, endPosition, out int pathLength) != null;
   }

   public int GetPathLength(GridPosition startPosition, GridPosition endPosition)
   {
      FindPath(startPosition, endPosition, out int pathLength);
      return pathLength;
   }
}