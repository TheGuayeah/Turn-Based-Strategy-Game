using UnityEngine;

public class UnitAnimator : MonoBehaviour
{
   private const string IS_WALKING = "IsWalking";
   private const string SHOOT = "Shoot";

   [SerializeField]
   private Animator animator;
   [SerializeField]
   private Transform bulletPrefab;
   [SerializeField]
   private Transform shootPoint;

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

   private void ShootAction_OnShoot(object sender, ShootAction.OnShootEventArgs e)
   {
      animator.SetTrigger(SHOOT);

      Transform bulletTransform = 
         Instantiate(bulletPrefab, shootPoint.position, Quaternion.identity);
      BulletProjectile bulletProjectile = bulletTransform.GetComponent<BulletProjectile>();
      
      Vector3 shootAtPosition = e.targetUnit.GetWorldPosition();
      shootAtPosition.y = shootPoint.position.y;
      bulletProjectile.Setup(shootAtPosition);
   }
}
