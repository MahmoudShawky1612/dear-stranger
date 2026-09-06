import { Router } from "express";
const router = Router();
router.get("/hello", (_request, response) => {
    response.json({
        message: "Hello from Dear Stranger's API!",
    });
});
export default router;
//# sourceMappingURL=hello.routes.js.map