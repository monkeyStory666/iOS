import Testing
import MEGASwift

struct StringEmailValidationTests {
    @Test func emailValidation() {
        #expect("rdu@mega.co.nz".isValidEmail)
        #expect("umaprahul26@gmail.com".isValidEmail)
        #expect("rdu+10@mega.co.nz".isValidEmail)
        #expect("special!characters@email.com".isValidEmail)

        #expect("invalid.email@missingtld".isValidEmail == false)
        #expect("missingat.com".isValidEmail == false)
        #expect("spaces in@email.com".isValidEmail == false)
        #expect("dot.at.end@".isValidEmail == false)
        #expect("double@@at.com".isValidEmail == false)
        #expect("invalid@missingdotcom".isValidEmail == false)
        #expect("@startwithat.com".isValidEmail == false)
        #expect(".startwithdot@email.com".isValidEmail == false)
        #expect("missingusername@.com".isValidEmail == false)
        #expect("missingusername@dot.".isValidEmail == false)
        #expect("missingusername@dotcom".isValidEmail == false)
        #expect("too@many@ats.com".isValidEmail == false)
        #expect("missingatandspace@ email.com".isValidEmail == false)
        #expect("missinglocalpart@".isValidEmail == false)
        #expect("missingtld@domain.".isValidEmail == false)
        #expect("invalid@-hyphenstart.com".isValidEmail == false)
        #expect("invalid@hyphen-end-.com".isValidEmail == false)
        #expect("missingatanddotcom".isValidEmail == false)
        #expect("double..dot@email.com".isValidEmail == false)
        #expect("invalid@email@.com".isValidEmail == false)
        #expect("invalid@.dot.com".isValidEmail == false)
        #expect("invalid@dotcom.".isValidEmail == false)
        #expect("invalid@[special]char.com".isValidEmail == false)
        #expect("invalid@ space.com".isValidEmail == false)
    }
}
