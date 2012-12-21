
cloneObject {
    name = "party",
    baseObject = "party",
    onDrawGui = function(ctx)
        encounters.update(ctx, self)
    end,
}

