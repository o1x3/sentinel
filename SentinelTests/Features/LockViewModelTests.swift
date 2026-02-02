import Testing
import Foundation
@testable import Sentinel

struct LockViewModelTests {

    @Test func setupRequiresMinimumPasswordLength() async {
        let vm = LockViewModel()
        let state = AppState()
        vm.password = "short"
        vm.confirmPassword = "short"

        await vm.setup(appState: state)

        #expect(state.isUnlocked == false)
        #expect(vm.errorMessage != nil)
    }

    @Test func setupRequiresMatchingPasswords() async {
        let vm = LockViewModel()
        let state = AppState()
        vm.password = "strongpassword123"
        vm.confirmPassword = "differentpassword"

        await vm.setup(appState: state)

        #expect(state.isUnlocked == false)
        #expect(vm.errorMessage?.contains("match") == true)
    }

    @Test func unlockFailsWithWrongPassword() async {
        let vm = LockViewModel()
        let state = AppState()

        // First setup
        vm.password = "correctpassword1"
        vm.confirmPassword = "correctpassword1"
        await vm.setup(appState: state)

        // Lock
        state.lock()

        // Try wrong password
        vm.password = "wrongpassword"
        await vm.unlock(appState: state)

        #expect(state.isUnlocked == false)
        #expect(vm.errorMessage != nil)
    }
}
