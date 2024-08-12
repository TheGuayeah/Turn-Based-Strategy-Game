using System;
using UnityEngine;

[RequireComponent(
   typeof(MoveAction), 
   typeof(SpinAction)
)]
public class Unit : MonoBehaviour
{
   public static event EventHandler OnAnyAcionPointsChanged;

   private const int MAX_ACTION_POINTS = 2;

   [SerializeField]
   private bool isEnemy;

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

      TurnSystem.Instance.OnTurnChanged += TurnSystem_OnTurnChanged;
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

      OnAnyAcionPointsChanged?.Invoke(this, EventArgs.Empty);
   }

   public int GetActionPoints()
   {
      return actionPoints;
   }

   private void TurnSystem_OnTurnChanged(object sender, EventArgs e)
   {
      if((IsEnemy() && !TurnSystem.Instance.IsPlayerTurn()) ||
         (!IsEnemy() && TurnSystem.Instance.IsPlayerTurn()))
      {
         actionPoints = MAX_ACTION_POINTS;

         OnAnyAcionPointsChanged?.Invoke(this, EventArgs.Empty);
      }
   }

   public bool IsEnemy()
   {
      return isEnemy;
   }
}
