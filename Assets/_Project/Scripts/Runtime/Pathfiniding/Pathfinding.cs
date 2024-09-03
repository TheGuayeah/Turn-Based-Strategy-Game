using System.Collections.Generic;
using UnityEngine;

public class Pathfinding : Singleton<Pathfinding>
{
   private const int MOVE_STRAIGHT_COST = 10;
   private const int MOVE_DIAGONAL_COST = 14;

   [SerializeField] private Transform gridDebugPrefab;

   private int width;
   private int height;
   private float cellSize;
   GridSystem<PathNode> gridSystem;

   protected override void Awake()
   {
      base.Awake();
      gridSystem = new GridSystem<PathNode>(10, 10, 2f,
         (GridSystem<PathNode> g, GridPosition gridPosition) =>
         new PathNode(gridPosition)
      );
      gridSystem.CreateDebugObjects(gridDebugPrefab, transform);
   }

   public List<GridPosition> FindPath(GridPosition startPosition, GridPosition endPosition)
   {
      List<PathNode> openList = new List<PathNode>(); //still searching
      List<PathNode> closedList = new List<PathNode>(); //already searched

      PathNode startNode = gridSystem.GetGridObject(startPosition);
      PathNode endNode = gridSystem.GetGridObject(endPosition);

      openList.Add(startNode);

      for (int x = 0; x < gridSystem.GetWidth(); x++)
      {
         for (int z = 0; z < gridSystem.GetHeight(); z++)
         {
            GridPosition gridPosition = new GridPosition(x, z);
            PathNode pathNode = gridSystem.GetGridObject(gridPosition);

            pathNode.SetGCost(int.MaxValue);
            pathNode.SetHCost(int.MaxValue);
            pathNode.CalculateFCost();
            pathNode.ResetCameFromPathNode();
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
            return CalculatePath(endNode);
         }

         openList.Remove(currentNode);
         closedList.Add(currentNode);

         foreach (PathNode neighbourNode in GetNeighbours(currentNode))
         {
            if (closedList.Contains(neighbourNode)) continue;

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

   private PathNode GetNode(int x, int z)
   {
      return gridSystem.GetGridObject(new GridPosition(x, z));
   }

   private List<PathNode> GetNeighbours(PathNode currentNode)
   {
      List<PathNode> neighbours = new List<PathNode>();

      GridPosition gridPosition = currentNode.GetGridPosition();

      if(gridPosition.x - 1 >= 0)
      {
         //Left
         neighbours.Add(GetNode(gridPosition.x - 1, gridPosition.z));

         if(gridPosition.z - 1 >= 0)
         {
            //LeftDown
            neighbours.Add(GetNode(gridPosition.x - 1, gridPosition.z - 1));
         }
         if (gridPosition.z + 1 < gridSystem.GetHeight())
         {
            //LeftUp
            neighbours.Add(GetNode(gridPosition.x - 1, gridPosition.z + 1));
         }
      }
      
      if (gridPosition.x + 1 < gridSystem.GetWidth())
      {
         //Right
         neighbours.Add(GetNode(gridPosition.x + 1, gridPosition.z));

         if (gridPosition.z - 1 >= 0)
         {
            //RightDown
            neighbours.Add(GetNode(gridPosition.x + 1, gridPosition.z - 1));
         }
         if (gridPosition.z + 1 < gridSystem.GetHeight())
         {
            //RightUp
            neighbours.Add(GetNode(gridPosition.x + 1, gridPosition.z + 1));
         }
      }

      if (gridPosition.z - 1 >= 0)
      {
         //Down
         neighbours.Add(GetNode(gridPosition.x, gridPosition.z - 1));
      }
      if (gridPosition.z + 1 < gridSystem.GetHeight())
      {
         //Up
         neighbours.Add(GetNode(gridPosition.x, gridPosition.z + 1));
      }

      return neighbours;
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
}