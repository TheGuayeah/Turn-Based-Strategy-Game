public class PathNode
{
   private GridPosition gridPosition;
   private int gCost;
   private int hCost;
   private int fCost;
   private PathNode cameFromPathNode;

   public PathNode(GridPosition gridPosition)
   {
      this.gridPosition = gridPosition;
   }

   public override string ToString()
   {
      return gridPosition.ToString();
   }

   public int GetGCost()
   {
      return gCost;
   }

   public int GetHCost()
   {
      return hCost;
   }

   public int GetFCost()
   {
      return fCost;
   }

   public void SetGCost(int value)
   {
      gCost = value;
   }

   public void SetHCost(int value)
   {
      hCost = value;
   }

   public void CalculateFCost()
   {
      fCost = gCost + hCost;
   }

   public void ResetCameFromPathNode()
   {
      cameFromPathNode = null;
   }

   public void SetCameFromPathNode(PathNode pathNode)
   {
      cameFromPathNode = pathNode;
   }

   public PathNode GetCameFromPathNode()
   {
      return cameFromPathNode;
   }

   public GridPosition GetGridPosition()
   {
      return gridPosition;
   }
}