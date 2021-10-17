(
Window.closeAll;
// new window
w = Window.new("Fall Creek Gorge Inlet", Rect.new(
	Window.screenBounds.width/2 - 610,
	Window.screenBounds.height/2 - 410,
	1230,
	830
	)).background_(Color.gray);
w.front;
w.alwaysOnTop_(true);

w.view.decorator_(FlowLayout(w.bounds, 10@10, 10@10));

// make two views (L/R)
// view size = 600 x 800
~views = Array.fill(2, {
	arg view;
	view = CompositeView(w, 600@800)
	.background_(Color.rand);
	//view.decorator_(FlowLayout(view.bounds, 5@5, 5@5));
	});

//~button = Button(~views[0], 50@50);
~buttonSize = 50;
~padding = 10;

// 600 x 800
// center x = 300, center y = 400
~buttonCords = [
	[~views[0].bounds.width/2-(~buttonSize/2), ~views[0].bounds.top], // 12:00
	[~views[0].bounds.width*0.75-(~buttonSize/2), ~views[0].bounds.height*0.25], // 1:30
	[~views[0].bounds.right-(~buttonSize+(~padding*2)), ~views[0].bounds.height/2-(~buttonSize/2)], // 3:00
	[~views[0].bounds.width*0.75-(~buttonSize/2), ~views[0].bounds.height*0.75-(~buttonSize/2)], // 4:30
	[~views[0].bounds.width/2-(~buttonSize/2), ~views[0].bounds.bottom-(~buttonSize+(~padding*2))], // 6:00
	[~views[0].bounds.width*0.25-(~buttonSize/2), ~views[0].bounds.height*0.75-(~buttonSize/2)], // 7:30
	[~views[0].bounds.left, ~views[0].bounds.height/2-(~buttonSize/2)], // 9:00
	[~views[0].bounds.width*0.25-(~buttonSize/2), ~views[0].bounds.height*0.25]
];

~buttonCords.postln;

~buttons = Array.fill(8, {
	arg i;
	var button;
	button = Button(~views[0],
		Rect(
			~buttonCords[i][0],
			~buttonCords[i][1],
			~buttonSize,
			~buttonSize))
			.string_(i.asString);
			i.postln;
			//.background_(Color.rand);
	});
)
