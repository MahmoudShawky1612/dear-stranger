import { Router } from "express";
import { z } from "zod";
const router = Router();
const testRequestSchema = z.object({
    message: z.string().min(1),
});
router.post("/test", (request, response) => {
    const result = testRequestSchema.safeParse(request.body);
    if (!result.success) {
        response.status(400).json({
            error: "Invalid request body",
        });
        return;
    }
    response.json({
        received: result.data.message,
    });
});
export default router;
//# sourceMappingURL=test.routes.js.map