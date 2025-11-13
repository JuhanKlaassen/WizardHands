using Godot;

[GlobalClass]
public partial class Player : CharacterBody2D
{
	[Export] private float _speed = 100.0f;
	[Export] private float _health = 100.0f;
	
	//private AnimationTree _animationTree;
	private InventorySystemGroup _inventoryGroup;
	
	public override void _Ready()
	{
		//_animationTree = GetNode<AnimationTree>("AnimationTree");
		_inventoryGroup = GetNode<InventorySystemGroup>("InventoryGroup");
		ReferenceCenter.Player = this;
	}

	public override void _PhysicsProcess(double delta)
	{
		Vector2 direction = Input.GetVector("movement_left", "movement_right", "movement_up", "movement_down");

		Velocity = direction * _speed;

		//_animationTree.Set("parameters/conditions/isMoving", direction.Length() > 0.01f);
		//_animationTree.Set("parameters/conditions/isIdle", direction.Length() <= 0.01f);
		//_animationTree.Set("parameters/Walk/blend_position", direction);

		MoveAndSlide();
	}
	
	public void Damage(float damage){
		if(_health - damage <= 0.0f){
			_health = 0.0f;
			GetNode<CanvasLayer>("%GameOver").Show();
			GetTree().Paused = true;
		}
		else
		{
			_health -= damage;	
		}
		GetNode<ProgressBar>("%HealthBar").Value = _health;
	}
	
	public void PickUpItem(Item item)
	{
		_inventoryGroup.AddItems(item);
	}
}
