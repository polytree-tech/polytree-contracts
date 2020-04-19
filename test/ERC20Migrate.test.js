const { ZERO_ADDRESS } = require('./helpers/constants');
const { setUpUnitTest } = require('./helpers/setUpUnitTest');

const {
    BN,           // Big Number support
    constants,    // Common constants, like the zero address and largest integers
    expectEvent,  // Assertions for emitted events
    expectRevert, // Assertions for transactions that should fail
    time,
    } = require('@openzeppelin/test-helpers');

contract('ERC20Migrate', function (accounts) {

    const [owner, manager, recoverer, ...others] = accounts;

    const users = others.slice(0,);
    let oldToken;
    let newToken;
    let migrate;

    let totalsupply = 1000000000;

    beforeEach(async function () {
        const { instances } = await setUpUnitTest(accounts);
        oldToken = instances.ERC20Token1;
        newToken = instances.ERC20Token2;
        migrate = instances.ERC20Migrate;
    });

    describe('roles', function(){
        it('set the contract owner as OutputManager role', async function () {
            (await migrate.isOutputManager(owner, { from: owner })).should.be.equal(true);
        });

        it('set the OutputManager role', async function () {
            const { logs } = await migrate.addOutputManager(manager, { from: owner });

            (await migrate.isOutputManager(manager, { from: owner })).should.be.equal(true);

            expectEvent.inLogs(logs, 'OutputManagerAdded', {
                account: manager,
            });
        });

        it('fails to set the OutputManager role if not called by a OutputManager', async function () {
            await expectRevert(migrate.addOutputManager(users[0], { from: users[0] }), "OutputManagerRole: caller does not have the OutputManager role");
        });

        it('renounce the OutputManager role', async function () {
            await migrate.addOutputManager(manager, { from: owner });
            const { logs } = await migrate.renounceOutputManager({ from: owner });

            (await migrate.isOutputManager(owner, { from: owner })).should.be.equal(false);

            expectEvent.inLogs(logs, 'OutputManagerRemoved', {
                account: owner,
            });
        });

        it('fails to renounce the OutputManager role if there are no other OutputManager accounts', async function () {
            await expectRevert(migrate.renounceOutputManager({ from: owner }), "Roles: there must be at least one account assigned to this role");
        });

        it('set the Recoverer role', async function () {
            const { logs } =  await migrate.addRecoverer(recoverer, { from: owner });

            (await migrate.isRecoverer(recoverer, { from: owner })).should.be.equal(true);

            expectEvent.inLogs(logs, 'RecovererAdded', {
                account: recoverer,
            });
        });

        it('fails to set the Recoverer role if not called by a Recoverer', async function () {
            await expectRevert(migrate.addRecoverer(users[0], { from: users[0] }), "RecovererRole: caller does not have the Recoverer role");
        });

        it('renounce the Recoverer role', async function () {
            await migrate.addRecoverer(recoverer, { from: owner });
            const { logs } = await migrate.renounceRecoverer({ from: owner });

            (await migrate.isRecoverer(owner, { from: owner })).should.be.equal(false);

            expectEvent.inLogs(logs, 'RecovererRemoved', {
                account: owner,
            });
        });

        it('fails to renounce the Recoverer role if there are no other Recoverer accounts', async function () {
            await expectRevert(migrate.renounceRecoverer({ from: owner }), "Roles: there must be at least one account assigned to this role");
        });
    });

    describe('OutputTokenManage', function () {
        it('set an active token manager', async function () {
            (await migrate.getActiveManager({from: owner})).should.be.equal(owner);
            await migrate.addOutputManager(manager, { from: owner });

            const { logs } = await migrate.setActive({from:manager});

            (await migrate.getActiveManager({from: owner})).should.be.equal(manager);
            
            expectEvent.inLogs(logs, 'ActiveOutputMangerSet', {
                activeManager: manager,
            });    
        });
    });

    describe('TokenMigrate', function () {
        describe('inputToken()', function () {
            it('returns the input token', async function () {
                (await migrate.inputToken({from: owner})).should.be.equal(oldToken.address);
            });
        });

        describe('outputToken()', function () {
            it('returns the output token', async function () {
                (await migrate.outputToken({from: owner})).should.be.equal(newToken.address);
            });
        });

        describe('initial tokensMigrated value', function () {
            it('returns 0', async function () {
                (await migrate.tokensMigrated({from: owner})).should.be.bignumber.equal(new BN(0));
            });
        });

        describe('initial tokensDistributed value', function () {
            it('returns 0', async function () {
                (await migrate.tokensDistributed({from: owner})).should.be.bignumber.equal(new BN(0));
            });
        });
    
        describe('StandardMigration', function () {
            const M90 = web3.utils.toWei(new BN(90000000));
            const M100 = web3.utils.toWei(new BN(100000000));
            beforeEach(async function () {
                newToken.approve(migrate.address, M90, { from: owner });
                oldToken.approve(migrate.address, M100, { from: owner });
            });
        });

        describe('StandardMigration.migrate', function () {
            const M90 = web3.utils.toWei(new BN(90000000));
            const M100 = web3.utils.toWei(new BN(100000000));
            it('reverts when the input allowance is 0', async function () {
                await oldToken.transfer(users[0], M100, { from: owner });
                
                await newToken.approve(migrate.address, M100, { from: owner });
                await expectRevert(migrate.migrate({ from: owner }), "StandardMigration: no input allowance");
            });

            it('reverts when the output allowance is 0', async function () {
                await oldToken.transfer(users[0], M100, { from: owner });
                (await oldToken.balanceOf(users[0])).should.be.bignumber.equal(M100);

                await oldToken.approve(migrate.address, M100, { from: users[0] });

                await expectRevert(migrate.migrate({ from: users[0] }), "StandardMigration: no output allowance");
            });

            it('reverts when the input allowance is larger than the output allowance', async function () {
                await oldToken.transfer(users[0], M100, { from: owner });

                await newToken.approve(migrate.address, M90, { from: owner });
                await oldToken.approve(migrate.address, M100, { from: users[0] });

                await expectRevert(migrate.migrate({ from: users[0] }), "StandardMigration: output allowance is less than the input allowance");
            });

            it('reverts when the migrator is the allowance token holder', async function () {
                await newToken.approve(migrate.address, M100, { from: owner });
                await oldToken.approve(migrate.address, M100, { from: owner });

                await expectRevert(migrate.migrate({ from: owner }), "TokenMigrate: migrator cannot be the distribution token approval holder");
            });

            it('successfully migrates for anyone else and tracks multiple migrations correctly', async function () {
                await oldToken.transfer(users[0], M100, { from: owner });
                await oldToken.transfer(users[1], M90, { from: owner });

                (await oldToken.balanceOf(users[0])).should.be.bignumber.equal(M100);
                (await oldToken.balanceOf(users[1])).should.be.bignumber.equal(M90);

                await newToken.approve(migrate.address, M100.add(M90), { from: owner });
                await oldToken.approve(migrate.address, M100, { from: users[0] });
                await oldToken.approve(migrate.address, M90, { from: users[1] });

                (await migrate.tokensMigrated()).should.be.bignumber.equal(new BN(0));
                (await migrate.tokensDistributed()).should.be.bignumber.equal(new BN(0));

                let { logs } = await migrate.migrate({ from: users[0] });

                await expectEvent.inLogs(logs, 'Migrated', {
                    migrator: users[0],
                    migratedTokens: M100.toString(),
                    distributedTokens: M100.toString()
                }); 

                (await migrate.tokensMigrated()).should.be.bignumber.equal(M100);
                (await migrate.tokensDistributed()).should.be.bignumber.equal(M100);
                
                const record0 = await migrate.getMigrationRecord(users[0], {from: owner});

                (record0[0]).should.be.bignumber.equal(M100);
                (record0[1]).should.be.bignumber.equal(M100);

                const newSupply0 = await newToken.totalSupply();

                (await newToken.balanceOf(owner)).should.be.bignumber.equal(newSupply0.sub(M100));
                (await newToken.balanceOf(users[0])).should.be.bignumber.equal(M100);
                (await oldToken.balanceOf(users[0])).should.be.bignumber.equal(new BN(0));

                (await oldToken.balanceOf(migrate.address)).should.be.bignumber.equal(M100);
                (await newToken.balanceOf(migrate.address)).should.be.bignumber.equal(new BN(0));

                await migrate.migrate({ from: users[1] });

                (await migrate.tokensMigrated()).should.be.bignumber.equal(M100.add(M90));
                (await migrate.tokensDistributed()).should.be.bignumber.equal(M100.add(M90));
                
                const record1 = await migrate.getMigrationRecord(users[1], {from: owner});
                
                (record1[0]).should.be.bignumber.equal(M90);
                (record1[1]).should.be.bignumber.equal(M90);

                const newSupply1 = await newToken.totalSupply();

                (await newToken.balanceOf(owner)).should.be.bignumber.equal(newSupply1.sub(M100).sub(M90));
                (await newToken.balanceOf(users[1])).should.be.bignumber.equal(M90);
                (await oldToken.balanceOf(users[1])).should.be.bignumber.equal(new BN(0));

                (await oldToken.balanceOf(migrate.address)).should.be.bignumber.equal(M100.add(M90));
                (await newToken.balanceOf(migrate.address)).should.be.bignumber.equal(new BN(0));
            });
        });
    });

    describe('recover', function () {
        const M90 = web3.utils.toWei(new BN(90000000));
        const M100 = web3.utils.toWei(new BN(100000000));

        it('reverts if non-manager tries to recover migrated tokens', async function () {
            await expectRevert(migrate.recoverERC20(oldToken.address, M90.add(new BN(1)), {from: users[0]}), "RecovererRole: caller does not have the Recoverer role");            
        });

        it('reverts if manager tries to recover migrated tokens', async function () {
            await oldToken.transfer(users[0], M100, { from: owner });
            await oldToken.transfer(migrate.address, M90, { from: owner });

            await newToken.approve(migrate.address, M100, { from: owner });
            await oldToken.approve(migrate.address, M100, { from: users[0] });

            await migrate.migrate({ from: users[0] });

            (await oldToken.balanceOf(migrate.address)).should.be.bignumber.equal(M100.add(M90));

            await expectRevert(migrate.recoverERC20(oldToken.address, M90.add(new BN(1)), {from: owner}), "TokenRecover: tokenAmount is greater than the available recovery amount");            
        });

        it('reverts if manager tries to recover too many tokens', async function () {
            await oldToken.transfer(users[0], M90, { from: owner });
            await oldToken.transfer(migrate.address, M100, { from: owner });

            await newToken.approve(migrate.address, M90, { from: owner });
            await oldToken.approve(migrate.address, M100, { from: users[0] });

            (await oldToken.balanceOf(migrate.address)).should.be.bignumber.equal(M100);

            await expectRevert(migrate.recoverERC20(oldToken.address, M100.add(new BN(1)), {from: owner}), "TokenRecover: tokenAmount is greater than the available recovery amount");  
             
        });

        it('recovers available tokens sent to the ERC20Token address', async function () {
            await oldToken.transfer(users[0], M100, { from: owner });
            await oldToken.transfer(migrate.address, M90, { from: owner });

            await newToken.approve(migrate.address, M100, { from: owner });
            await oldToken.approve(migrate.address, M100, { from: users[0] });

            await migrate.migrate({ from: users[0] });

            (await oldToken.balanceOf(migrate.address)).should.be.bignumber.equal(M100.add(M90));

            await migrate.recoverERC20(oldToken.address, M90, {from: owner});
            
            (await oldToken.balanceOf(migrate.address)).should.be.bignumber.equal(M100);
            
        });
    });
});