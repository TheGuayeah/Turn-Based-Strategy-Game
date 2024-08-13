using UnityEngine;

public class UnitAnimator : MonoBehaviour
{
   private const string IS_WALKING = "IsWalking";
   private const string SHOOT = "Shoot";

   [SerializeField]
   private Animator animator;

   private void Awake()
   {
      if(TryGetComponent<MoveAction>(out MoveAction moveAction))
      {
         moveAction.OnStartMoving += MoveAction_OnStartMoving;
         moveAction.OnStopMoving += MoveAction_OnStopMoving;
      }
      if(TryGetComponent<ShootAction>(out ShootAction shootAction))
      {
         shootAction.OnShoot += ShootAction_OnShoot;
      }
   }

   private void MoveAction_OnStartMoving(object sender, System.EventArgs e)
   {
      animator.SetBool(IS_WALKING, true);
   }

   private void MoveAction_OnStopMoving(object sender, System.EventArgs e)
   {
      animator.SetBool(IS_WALKING, false);
   }

   private void ShootAction_OnShoot(object sender, System.EventArgs e)
   {
      animator.SetTrigger(SHOOT);
   }
}
