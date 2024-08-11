using UnityEngine;

[RequireComponent(
   typeof(MoveAction), 
   typeof(SpinAction)
)]
public class Unit : MonoBehaviour
{
   private GridPosition gridPosition;
   private MoveAction moveAction;
   private SpinAction spinAction;
   private BaseAction[] baseActions;
   private int actionPoints = 2;

   private void Awake()
   {
      moveAction = GetComponent<MoveAction>();
      spinAction = GetComponent<SpinAction>();
      baseActions = GetComponents<BaseAction>();
   }

   private void Start()
   {
      gridPosition = LevelGrid.Instance.GetGridPosition(transform.position);
      LevelGrid.Instance.AddUnitAtGridPosition(gridPosition, this);
   }

   private void Update()
   {
      GridPosition newGridPosition = LevelGrid.Instance.GetGridPosition(transform.position);

      if(newGridPosition != gridPosition)
      {
         LevelGrid.Instance.UnitMovedGridPosition(this, gridPosition, newGridPosition);
         gridPosition = newGridPosition;
      }
   }

   public MoveAction GetMoveAction()
   {
      return moveAction;
   }

   public SpinAction GetSpinAction()
   {
      return spinAction;
   }

   public GridPosition GetGridPosition()
   {
      return gridPosition;
   }

   public BaseAction[] GetBaseActions()
   {
      return baseActions;
   }

   public bool TrySpendActionPoints(BaseAction baseAction)
   {
      if (HasEnoughActionPoints(baseAction))
      {
         SpendActionPoints(baseAction.GetActionPointsCost());
         return true;
      }

      return false;
   }

   public bool HasEnoughActionPoints(BaseAction baseAction)
   {
      return actionPoints >= baseAction.GetActionPointsCost();
   }

   private void SpendActionPoints(int amount)
   {
      actionPoints -= amount;
   }

   public int GetActionPoints()
   {
      return actionPoints;
   }
}
