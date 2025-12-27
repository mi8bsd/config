@RestController
@RequestMapping("/api/v1/jails")
public class JailController {

    private final JailService jailService;

    public JailController(JailService jailService) {
        this.jailService = jailService;
    }

    @GetMapping
    public List<JailInfo> listJails() {
        return jailService.listJails();
    }
}
